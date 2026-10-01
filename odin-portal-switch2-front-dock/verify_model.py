"""Regenerate one-piece SIDE-ROUTED adapter and verify geometry.
uv run --python 3.11 --with trimesh --with scipy --with networkx --with matplotlib --no-project python verify_model.py
OpenSCAD PNG rendering needs a graphics display; OPENSCAD_BIN may override executable.
"""
import concurrent.futures, hashlib, json, math, os, re, shutil, subprocess, tempfile
from pathlib import Path
import numpy as np
import trimesh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.collections import PolyCollection
from matplotlib.patches import Rectangle, Polygon

ROOT=Path(__file__).resolve().parent
SCAD=ROOT/'odin_portal_dock.scad'
EXE=os.environ.get('OPENSCAD_BIN') or shutil.which('openscad') or '/opt/data/tools/openscad/runtime/usr/bin/openscad'
TMP=Path(tempfile.mkdtemp(prefix='odin-side-check-'))
source=SCAD.read_text()
def value(name):
    m=re.search(r'^'+re.escape(name)+r'=([0-9.\-]+);',source,re.M)
    assert m,name
    return float(m.group(1))
angle=value('tilt'); a=math.radians(angle)
gap=value('odin_thickness')+2*value('tpu_per_face')+value('fit_clearance')
depth=value('reference_depth_envelope')-value('insert_depth_clearance')
width=value('reference_insert_width')-value('insert_width_clearance')
tabletop=value('insertion_height')-value('seating_stop_to_table')
seat_z=tabletop+value('seat_above_table'); sy=value('seat_y')
results={}

def render(job):
    part,out,png=job
    cmd=[EXE,'--render','-D',f'part="{part}"','-o',str(out)]
    if png:
        cmd.extend(['--autocenter','--viewall','--projection=ortho','--imgsize=1400,1000','--colorscheme=Metallic','--camera=0,-30,20,65,0,35,350'])
    cmd.append(str(SCAD))
    p=subprocess.run(cmd,capture_output=True,text=True)
    empty='Current top level object is empty.' in p.stderr
    check=part.endswith('_check')
    assert (p.returncode==1 and empty) if check else p.returncode==0,(part,p.returncode,p.stderr)
    print(part,'PASS',('empty intersection' if check else out.name),flush=True)
    return part,{'exit_code':p.returncode,'expected_empty_intersection':empty,'log':p.stderr}

jobs=[('adapter',ROOT/'adapter.stl',False),('assembled',ROOT/'preview.png',True),
      ('adapter',ROOT/'print-orientation.png',True)]
for name in ['cable_check','dock_clearance_check','device_clearance_check','table_check','cable_device_check','cable_dock_check','dock_usb_entry_check']:
    jobs.append((name,TMP/(name+'.stl'),False))
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as ex:
    for part,result in ex.map(render,jobs): results.setdefault(part,[]).append(result)

mesh=trimesh.load_mesh(ROOT/'adapter.stl',process=True)
assert mesh.is_watertight and mesh.is_volume
assert len(mesh.split())==1,'Must be ONE connected printed solid'
assert mesh.bounds[0,2]>=-1e-4,'Print below bed'
assembled=mesh.copy(); assembled.apply_translation([0,0,-depth/2])
assembled.apply_transform(trimesh.transformations.rotation_matrix(math.pi/2,[1,0,0]))
assert abs(assembled.bounds[0,2]-tabletop)<1e-3
assert value('front_base_rear') < -value('dock_depth')/2
assert value('side_arm_inner_x') > value('dock_width')/2
sections=[]
for h in (5,15,35,49):
    cut=assembled.section(plane_origin=[0,0,h],plane_normal=[0,0,1]); assert cut is not None
    # Exclude separately located external side link, not the docking blade.
    v=cut.vertices[(np.abs(cut.vertices[:,1])<=depth/2+1e-3)&(np.abs(cut.vertices[:,0])<=value('reference_insert_width')/2+1e-3)]
    assert len(v)
    bounds=np.array([v.min(axis=0),v.max(axis=0)])
    assert bounds[0,0]>=-width/2-1e-3 and bounds[1,0]<=width/2+1e-3
    assert bounds[0,1]>=-depth/2-1e-3 and bounds[1,1]<=depth/2+1e-3
    sections.append({'height_mm':h,'bounds_mm':bounds.tolist()})

# Exact parameterized centerline, for side/top routing diagrams.
def yz(y,z): return np.array([sy+y*math.cos(a)+z*math.sin(a),seat_z-y*math.sin(a)+z*math.cos(a)])
height=value('odin_height')+6; mid=gap/2
holder_height=value('male_height')+value('housing_floor')
outlet=np.array([0,*yz(mid,-holder_height)])
direction=np.array([0,math.sin(a),math.cos(a)])
r=value('cable_bend_radius'); cy=value('female_center_y'); cx=value('side_column_x'); hz=value('side_exit_height')
return_y=outlet[1]-r*math.sin(a); return_z=outlet[2]-r*math.cos(a)
u=np.linspace(0,math.pi/2,40)
points=[np.array([0,cy,20]),np.array([0,cy,hz-r])]
points.extend(np.column_stack((r-r*np.cos(u),np.full_like(u,cy),hz-r+r*np.sin(u))))
points.append(np.array([cx-r,cy,hz]))
points.extend(np.column_stack((cx-r+r*np.sin(u),np.full_like(u,cy),hz-r+r*np.cos(u))))
points.append(np.array([cx,cy,return_z+r]))
points.extend(np.column_stack((np.full_like(u,cx),cy-r+r*np.cos(u),return_z+r-r*np.sin(u))))
points.append(np.array([cx,return_y+r,return_z]))
points.extend(np.column_stack((cx-r+r*np.cos(u),return_y+r-r*np.sin(u),np.full_like(u,return_z))))
points.append(np.array([r,return_y,return_z]))
points.extend(outlet+r*(1-math.sin(t))*np.array([1,0,0])-r*math.cos(t)*direction for t in u)
points.append(outlet+4*direction); route=np.array(points)
centroid_yz=yz(gap/2,height/2)
margin=min(centroid_yz[0]-value('front_base_front'),value('front_base_rear')-centroid_yz[0],value('front_base_width')/2)
assert margin>0
assert route[:,2].min()-3>tabletop

fig,axs=plt.subplots(1,2,figsize=(17,10))
# Side projection: right arm/cable are outside page plane, stated explicitly.
ax=axs[0]
ax.add_collection(PolyCollection(assembled.triangles[:,:,[1,2]],facecolor='#4b7891',edgecolor='#35566b',linewidth=.1))
hd=value('dock_depth')/2
for y,w in [(-hd,hd-8),(8,hd-8)]: ax.add_patch(Rectangle((y,tabletop),w,value('dock_height'),facecolor='#aaaaaa',alpha=.25,edgecolor='#555555'))
corners=[yz(1,0),yz(gap-1,0),yz(gap-1,height),yz(1,height)]
ax.add_patch(Polygon(corners,facecolor='#6ebec6',alpha=.22,edgecolor='#267c87'))
ax.plot(route[:,1],route[:,2],color='#e78325',linewidth=2.4)
ax.plot([centroid_yz[0]]*2,[centroid_yz[1],tabletop],linestyle='--',color='#222222',linewidth=1)
ax.axhline(tabletop,color='#222222',linewidth=2)
ax.annotate('LOWER FRONT CRADLE\n55 mm seat datum above table',xy=(-66,-8),xytext=(-124,97),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.annotate('Right-side link is OUTSIDE dock\n(no overhead front bridge)',xy=(-2,15),xytext=(28,70),arrowprops={'arrowstyle':'->'},fontsize=9)
ax.annotate('Front sole and Nintendo dock\nrest on SAME tabletop',xy=(-72,tabletop),xytext=(-124,tabletop+20),arrowprops={'arrowstyle':'->'},fontsize=9)
ax.set_xlim(-130,122);ax.set_ylim(tabletop-12,116);ax.set_aspect('equal');ax.grid(alpha=.15)
ax.set_title('Side projection — side cable is outside wall in X',fontsize=11)
ax.set_xlabel('Front ← Y → rear / mm');ax.set_ylabel('Z / mm relative to insert bottom')
# Top projection distinguishes side route from an impossible through-wall path.
ax=axs[1]
ax.add_patch(Rectangle((-value('dock_width')/2,-hd),value('dock_width'),value('dock_depth'),facecolor='#aaaaaa',alpha=.23,edgecolor='#666666'))
ax.add_collection(PolyCollection(assembled.triangles[:,:,[0,1]],facecolor='#4b7891',edgecolor='#35566b',linewidth=.09))
body_y=np.array(corners)[:,0]; ax.add_patch(Rectangle((-value('odin_width')/2,body_y.min()),value('odin_width'),body_y.max()-body_y.min(),facecolor='#6ebec6',alpha=.12,edgecolor='#267c87'))
ax.plot(route[:,0],route[:,1],color='#e78325',linewidth=2.5)
ax.scatter([0],[centroid_yz[0]],color='#222222',s=25)
ax.annotate('INSERT',xy=(-30,0),xytext=(-117,23),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.annotate('RIGHT-SIDE EXIT',xy=(108,-1.8),xytext=(36,25),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.annotate('Side arm + ground link\nconnects into front base',xy=(109,-31),xytext=(9,-113),arrowprops={'arrowstyle':'->'},fontsize=9)
ax.set_xlim(-145,145);ax.set_ylim(-126,40);ax.set_aspect('equal');ax.grid(alpha=.15)
ax.set_title('Top projection — cable goes AROUND the right wall',fontsize=11)
ax.set_xlabel('X / mm');ax.set_ylabel('Front ← Y → rear / mm')
fig.suptitle('ONE-PIECE SIDE-ROUTED ADAPTER | tabletop-supported Odin cradle\nCyan/gray are illustrative device/dock envelopes; black dashed line is envelope-centroid projection, not measured COM',fontsize=13)
fig.tight_layout();fig.savefig(ROOT/'placement.png',dpi=155);plt.close(fig)

# Detailed actual mount sections, with EXPLICITLY schematic cable/dock hardware.
from matplotlib.patches import FancyBboxPatch, Circle
fig,axs=plt.subplots(1,2,figsize=(14,9))
face_z=value('female_socket_face_z')
for ax,normal,origin,plane in [(axs[0],[0,1,0],[0,cy,0],(0,2)),(axs[1],[1,0,0],[value('female_anchor_x'),0,0],(1,2))]:
    section=assembled.section(plane_origin=origin,plane_normal=normal)
    assert section is not None
    for line in section.discrete:
        ax.plot(line[:,plane[0]],line[:,plane[1]],color='#285c79',linewidth=2)
    ax.axhline(face_z,color='#b23930',linestyle='--',linewidth=1)
    ax.set_ylim(face_z-10,face_z+38);ax.set_aspect('equal');ax.grid(alpha=.16)
# Front cut at socket center: socket down, OEM male entering from below.
ax=axs[0]
ax.add_patch(Rectangle((-10.8,face_z),21.6,30,facecolor='#edb878',alpha=.22,edgecolor='none'))
ax.add_patch(FancyBboxPatch((-8.5,face_z),17,28,boxstyle='round,pad=0,rounding_size=.7',facecolor='#cbd0d4',edgecolor='#555555',linewidth=1.5))
ax.add_patch(Rectangle((-4.7,face_z),9.4,7,facecolor='white',edgecolor='#555555'))
ax.add_patch(Rectangle((-4.0,face_z-7),8,10,facecolor='#919ba3',edgecolor='#333333'))
for x in [-value('female_anchor_x'),value('female_anchor_x')]:
    for z in [value('female_anchor_low'),value('female_anchor_high')]:
        ax.add_patch(Circle((x,z+face_z),value('female_anchor_diameter')/2,fill=False,edgecolor='#d5791c',linestyle='--'))
ax.plot([0,0],[face_z+28,face_z+36],color='#d5791c',linewidth=4)
ax.annotate('Extension FEMALE end\nfixed INSIDE insert',xy=(-7,face_z+15),xytext=(-26,face_z+33),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.annotate('Nintendo dock MALE plug\nenters from below',xy=(0,face_z-4),xytext=(-25,face_z-9),arrowprops={'arrowstyle':'->'},fontsize=9)
ax.annotate('',xy=(16,face_z+1),xytext=(16,face_z+12),arrowprops={'arrowstyle':'->','linewidth':2,'color':'#285c79'})
ax.text(18,face_z+6,'Adapter\nslides DOWN',fontsize=9)
ax.set_xlim(-28,31);ax.set_xlabel('X / mm');ax.set_ylabel('Z relative to reference / mm');ax.set_title('Front section through socket center')
# Side at retention key: orange silicone wraps body and keys into rear wall.
ax=axs[1]
ax.add_patch(Rectangle((-depth/2,face_z),depth/2+cy+value('female_depth')/2,30,facecolor='#edb878',alpha=.3,edgecolor='none'))
ax.add_patch(Rectangle((cy-4,face_z),8,28,facecolor='#cbd0d4',edgecolor='#555555'))
for z in [value('female_anchor_low'),value('female_anchor_high')]:
    ax.add_patch(Rectangle((cy+value('female_depth')/2,z+face_z-value('female_anchor_diameter')/2),depth/2-(cy+value('female_depth')/2),value('female_anchor_diameter'),facecolor='#e6963d',edgecolor='none'))
ax.annotate('Keyed silicone retains housing\nTrim flush with insert faces',xy=(depth/2-1,face_z+20),xytext=(10,face_z+34),arrowprops={'arrowstyle':'->'},fontsize=9)
ax.annotate('Receiving face at datum Z=0\nSocket opens DOWN',xy=(cy,face_z),xytext=(10,face_z+6),arrowprops={'arrowstyle':'->'},fontsize=9)
ax.set_xlim(-15,34);ax.set_xlabel('Y / mm');ax.set_title('Side section at silicone-retention key')
fig.suptitle('DOCKING CONNECTION: OEM male USB-C ↑ female extension socket in printed insert\nBlue = actual print sections | gray hardware shapes are SCHEMATIC, not LEIRUI measurements or a verified engagement-depth model',fontsize=12)
fig.tight_layout();fig.savefig(ROOT/'dock-interface.png',dpi=160);plt.close(fig)

report={'source_sha256':hashlib.sha256(SCAD.read_bytes()).hexdigest(),
 'adapter_stl_sha256':hashlib.sha256((ROOT/'adapter.stl').read_bytes()).hexdigest(),
 'printed_parts':1,'connected_solids':1,'watertight':True,'positive_volume':True,
 'print_dimensions_mm':mesh.extents.tolist(),'assembled_bounds_mm':assembled.bounds.tolist(),
 'volume_mm3':float(mesh.volume),'triangles':len(mesh.faces),'insertion_envelope_mm':[width,depth,value('insertion_height')],
 'insertion_sections':sections,'cradle_depth_clearance_mm':gap,
 'cable_test_diameter_mm':6,'side_exit_height_relative_to_insert_mm':hz,
 'right_side_route':True,'over_front_bridge_present':False,'seat_above_table_mm':value('seat_above_table'),
 'tabletop_plane_z_mm':tabletop,'model_min_z_mm':float(assembled.bounds[0,2]),
 'front_base_level_with_modeled_dock':True,'front_base_beneath_dock':False,
 'side_arm_clearance_to_official_width_mm':value('side_arm_inner_x')-value('dock_width')/2,
 'handheld_envelope_centroid_yz_mm':centroid_yz.tolist(),'projection_margin_mm':float(margin),
 'cable_min_center_height_above_table_mm':float(route[:,2].min()-tabletop),
 'cable_route_positive_volume_collision':False,'cable_intersects_device':False,'cable_intersects_dock':False,
 'odin_tpu_envelope_positive_volume_collision':False,'illustrative_dock_walls_positive_volume_collision':False,
 'model_or_cable_below_table':False,'device_check_seat_contact_exclusion_mm':value('eps'),
 'dock_side_connection':{'female_cable_end_mount_in_insert':True,'housing_retention':'pocket shoulder and keyed cured silicone; actual cable must be aligned first','socket_face_position_mm':[0,cy,value('female_socket_face_z')],'socket_facing_axis':[0,0,-1],'silicone_anchor_holes':4,'reference_male_entry_keepout_mm':[value('dock_usb_access_width'),value('dock_usb_access_depth')],'printed_usb_entry_clear':True,'automatic_connection_physically_verified':False},
 'physical_fit_verified':False,'actual_loaded_balance_verified':False,
 'assumptions':['3 mm TPU allowance per face, not measured.','Oversized cable pockets for silicone adjustment, not measured housings.','Simplified dock walls use official external dimensions; actual slot placement/vents not fully measured.','115 mm seating-stop height is an official overall-height proxy; verify your real stop-to-table datum.','Envelope centroid is not measured real-device COM.'],
 'openscad_results':results}
(ROOT/'validation.json').write_text(json.dumps(report,indent=2))
print(json.dumps({k:v for k,v in report.items() if k!='openscad_results'},indent=2))
