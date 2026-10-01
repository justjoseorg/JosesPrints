"""Build/verify TWO independent pieces: insert+winder and Odin cradle.
uv run --python 3.11 --with trimesh --with scipy --with networkx --with matplotlib --no-project python verify_model.py
OpenSCAD PNG rendering requires DISPLAY/OpenGL; OPENSCAD_BIN overrides executable.
"""
import concurrent.futures, hashlib, json, math, os, re, shutil, subprocess, tempfile
from pathlib import Path
import numpy as np
import trimesh
from scipy.spatial import cKDTree
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.collections import PolyCollection
from matplotlib.patches import Rectangle, Polygon, FancyBboxPatch, Circle
ROOT=Path(__file__).resolve().parent
SCAD=ROOT/'odin_portal_dock.scad'
EXE=os.environ.get('OPENSCAD_BIN') or shutil.which('openscad') or '/opt/data/tools/openscad/runtime/usr/bin/openscad'
TMP=Path(tempfile.mkdtemp(prefix='odin-two-piece-'))
source=SCAD.read_text()
def value(name):
    m=re.search(r'(?:^|;)\s*'+re.escape(name)+r'=([0-9.\-]+);',source,re.M)
    assert m,name
    return float(m.group(1))
depth=value('reference_depth_envelope')-value('insert_depth_clearance')
width=value('reference_insert_width')-value('insert_width_clearance')
tabletop=value('insertion_height')-value('seating_stop_to_table')
center_y=(value('front_base_front')+value('front_base_rear'))/2
preview_y=value('preview_cradle_offset_y');a=math.radians(value('tilt'))
gap=value('odin_thickness')+2*value('tpu_per_face')+value('fit_clearance')
results={}
def render(job):
    part,out,png,extra=job
    cmd=[EXE,'--render','-D',f'part="{part}"','-o',str(out)]
    for define in extra: cmd.extend(['-D',define])
    if png: cmd.extend(['--autocenter','--viewall','--projection=ortho','--imgsize=1500,1000','--colorscheme=Metallic','--camera=0,-30,25,65,0,35,400'])
    cmd.append(str(SCAD));p=subprocess.run(cmd,capture_output=True,text=True)
    empty='Current top level object is empty.' in p.stderr
    if part.endswith('_check'): assert p.returncode==1 and empty,(part,p.stderr)
    else:
        assert p.returncode==0,(part,p.stderr)
        assert 'may not be a valid 2-manifold' not in p.stderr,(part,p.stderr)
    print(part,'PASS',('empty intersection' if empty else out.name),flush=True)
    return part,{'exit_code':p.returncode,'expected_empty_intersection':empty,'log':p.stderr,'defines':extra}
jobs=[('adapter',ROOT/'adapter.stl',False,[]),('cradle',ROOT/'cradle.stl',False,[]),
      ('assembled',ROOT/'preview.png',True,[]),('layout',ROOT/'print-orientation.png',True,[])]
for p in ['dock_usb_entry_check','adapter_dock_check','adapter_wire_check','coil_check','coil_dock_check','cradle_device_check','cradle_wire_check','cradle_table_check','parts_collision_check','preview_device_check']:
    jobs.append((p,TMP/(p+'.stl'),False,[]))
# Explicit decoupling test: changing dock preview height must not alter either print.
alt_height=value('seating_stop_to_table')+10
for p in ['adapter','cradle']:
    jobs.append((p,TMP/(p+'-alternate-height.stl'),False,[f'seating_stop_to_table={alt_height}']))
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as ex:
    for p,r in ex.map(render,jobs):results.setdefault(p,[]).append(r)
meshes={};parts={};independence={}
for name in ['adapter','cradle']:
    m=trimesh.load_mesh(ROOT/(name+'.stl'),process=True)
    assert m.is_watertight and m.is_volume and len(m.split())==1,name
    assert m.bounds[0,2]>=-1e-4,name
    alt=trimesh.load_mesh(TMP/(name+'-alternate-height.stl'))
    error=max(cKDTree(m.vertices).query(alt.vertices)[0].max(),cKDTree(alt.vertices).query(m.vertices)[0].max())
    assert error<.001,(name,error)
    assert np.allclose(m.extents,alt.extents,atol=.001)
    meshes[name]=m
    parts[name]={'watertight':True,'positive_volume':True,'connected_solids':1,'dimensions_mm':m.extents.tolist(),
                 'volume_mm3':float(m.volume),'triangles':len(m.faces),'sha256':hashlib.sha256((ROOT/(name+'.stl')).read_bytes()).hexdigest()}
    independence[name]={'tested_seating_stop_heights_mm':[value('seating_stop_to_table'),alt_height],'max_vertex_deviation_mm':float(error)}
assert len(list(ROOT.glob('*.stl')))==2,'Exactly two printable files required'
# Installed example transforms. Cradle can be moved freely; this is only a preview.
adapter=meshes['adapter'].copy();adapter.apply_translation([0,0,-depth/2]);adapter.apply_transform(trimesh.transformations.rotation_matrix(math.pi/2,[1,0,0]))
cradle=meshes['cradle'].copy();cradle.apply_translation([0,center_y+preview_y,tabletop])
sections=[]
for h in [5,15,35,49]:
    s=adapter.section(plane_origin=[0,0,h],plane_normal=[0,0,1]);assert s is not None
    v=s.vertices[np.abs(s.vertices[:,1])<=depth/2+1e-3]
    b=np.array([v.min(axis=0),v.max(axis=0)])
    assert b[0,0]>=-width/2-.001 and b[1,0]<=width/2+.001
    assert b[0,1]>=-depth/2-.001 and b[1,1]<=depth/2+.001
    sections.append({'height_mm':h,'bounds_mm':b.tolist()})
assert abs(cradle.bounds[0,2]-tabletop)<.001
r=value('winder_core_radius')+value('coil_test_diameter')/2+.2
wx=value('winder_x');wy=value('winder_y');spacing=value('winder_spacing')
wtop=value('insertion_height')+value('flange_height')-1+value('winder_deck_thickness')
wrap_perimeter=2*spacing+2*math.pi*r
# One displayed coil, actual capacity check covers two sample loops.
u=np.linspace(math.pi/2,3*math.pi/2,60)
coil=[np.array([wx-spacing/2+r*math.cos(t),wy+r*math.sin(t),wtop+3.3]) for t in u]
coil.append(np.array([wx+spacing/2,wy-r,wtop+3.3]))
u=np.linspace(-math.pi/2,math.pi/2,60)
coil.extend(np.array([wx+spacing/2+r*math.cos(t),wy+r*math.sin(t),wtop+3.3]) for t in u)
coil.append(coil[0]);coil=np.array(coil)
# Native device envelope transformed into the freely placed example cradle.
def yz(y,z):return np.array([value('seat_y')+y*math.cos(a)+z*math.sin(a)+preview_y,
                            tabletop+value('seat_above_table')-y*math.sin(a)+z*math.cos(a)])
height=value('odin_height')+6
corners=np.array([yz(1,0),yz(gap-1,0),yz(gap-1,height),yz(1,height)])
# Side and top views: no imaginary rigid link is drawn.
fig,axs=plt.subplots(1,2,figsize=(17,10));hd=value('dock_depth')/2
for ax,plane in zip(axs,[(1,2),(0,1)]):
    ax.add_collection(PolyCollection(adapter.triangles[:,:,[*plane]],facecolor='#4b7891',edgecolor='#35566b',linewidth=.09))
    ax.add_collection(PolyCollection(cradle.triangles[:,:,[*plane]],facecolor='#dd9854',edgecolor='#955b21',linewidth=.09))
    ax.plot(coil[:,plane[0]],coil[:,plane[1]],color='#e45324',linewidth=2.5)
    ax.set_aspect('equal');ax.grid(alpha=.15)
ax=axs[0]
for y,w in [(-hd,hd-8),(8,hd-8)]:ax.add_patch(Rectangle((y,tabletop),w,value('dock_height'),facecolor='#aaaaaa',alpha=.22,edgecolor='#555555'))
ax.add_patch(Polygon(corners,facecolor='#62b7be',alpha=.16,edgecolor='#267c87'))
ax.axhline(tabletop,color='#333333',linewidth=1.5)
ax.annotate('PART A: insert + built-in winder',xy=(-14,wtop+7),xytext=(20,109),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.annotate('PART B: independent Odin cradle\nNo matched-height requirement',xy=(-92,tabletop+32),xytext=(-146,88),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.set_xlim(-158,148);ax.set_ylim(tabletop-12,130)
ax.set_xlabel('Front ← Y → rear / mm');ax.set_ylabel('Z / mm relative to insert');ax.set_title('Example placement — cable only between pieces')
ax=axs[1]
ax.add_patch(Rectangle((-value('dock_width')/2,-hd),value('dock_width'),value('dock_depth'),facecolor='#aaaaaa',alpha=.2,edgecolor='#666666'))
ax.add_patch(Rectangle((-value('odin_width')/2,corners[:,0].min()),value('odin_width'),np.ptp(corners[:,0]),facecolor='#62b7be',alpha=.13,edgecolor='#267c87'))
ax.annotate('Wind only surplus cable\nUnwind to adjust reach',xy=(wx,wy-r),xytext=(-123,25),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.annotate('Cradle can move freely\nwithin cable reach',xy=(0,center_y+preview_y),xytext=(30,-142),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.set_xlim(-145,145);ax.set_ylim(-151,40);ax.set_xlabel('X / mm');ax.set_ylabel('Y / mm');ax.set_title('Top view — no side arm or mechanical attachment')
fig.suptitle('TWO PIECES | dock insert with cable winder + standalone TPU-friendly Odin cradle\nExample only: wind/unwind your existing cable to suit the actual placement; hardware envelopes are illustrative',fontsize=13)
fig.tight_layout();fig.savefig(ROOT/'placement.png',dpi=155);plt.close(fig)
# Winder detail: ghosted keeper outlines and actual sectional clearance.
fig,axes=plt.subplots(1,2,figsize=(16,8));ax=axes[0]
ax.add_collection(PolyCollection(adapter.triangles[:,:,[0,1]],facecolor='#4b7891',edgecolor='#35566b',linewidth=.08))
for x in [wx-spacing/2,wx+spacing/2]:
    ax.add_patch(Circle((x,wy),value('winder_flange_radius'),facecolor='#d9e4eb',alpha=.35,edgecolor='#24495e',linewidth=1.5))
    ax.add_patch(Circle((x,wy),value('winder_core_radius'),facecolor='#f6f3e8',edgecolor='#24495e',linewidth=2))
ax.plot(coil[:,0],coil[:,1],color='#e45324',linewidth=4)
ax.annotate('Wrap around BOTH cores\nKeeper lips are ghosted to show cable',xy=(wx-spacing/2-r,wy),xytext=(6,-52),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.text(6,13,f'Core radius {value("winder_core_radius"):g} mm; gap {value("winder_gap"):g} mm',fontsize=10)
ax.text(6,7,f'Example 6 mm cable: ~{wrap_perimeter:.1f} mm per complete turn',fontsize=9)
ax.set_xlim(3,121);ax.set_ylim(-58,20);ax.set_aspect('equal');ax.grid(alpha=.15)
ax.set_title('Top view — cores visible through ghosted keeper lips');ax.set_xlabel('X / mm');ax.set_ylabel('Y / mm')
ax=axes[1];sec=adapter.section(plane_origin=[0,wy,0],plane_normal=[0,1,0]);assert sec is not None
for line in sec.discrete:ax.plot(line[:,0],line[:,2],color='#24495e',linewidth=2)
for x in [wx-spacing/2-r,wx+spacing/2+r]:
    for z in [wtop+3.3,wtop+3.3+value('coil_test_diameter')+.8]:ax.add_patch(Circle((x,z),value('coil_test_diameter')/2,facecolor='#e45324',edgecolor='#8e321a'))
ax.annotate(f'{value("winder_gap"):g} mm winding space\nCable sits UNDER keeper lips',xy=(wx+spacing/2+r,wtop+7),xytext=(25,wtop+22),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.text(24,wtop-8,'Two 6 mm loop cross-sections show tested space only.\nWrap only slack your actual cable can spare.',fontsize=9)
ax.set_xlim(21,115);ax.set_ylim(wtop-12,wtop+28);ax.set_aspect('equal');ax.grid(alpha=.15)
ax.set_title('Actual adapter section — protected winding area');ax.set_xlabel('X / mm');ax.set_ylabel('Z / mm')
fig.suptitle('Built-in adjustable cable storage — no third printed part',fontsize=14)
fig.tight_layout();fig.savefig(ROOT/'cable-winder.png',dpi=155);plt.close(fig)
# Socket mounting diagram from actual adapter sections; gray hardware schematic.
fig,axs=plt.subplots(1,2,figsize=(14,9));cy=value('female_center_y');face=value('female_socket_face_z')
for ax,normal,origin,plane in [(axs[0],[0,1,0],[0,cy,0],(0,2)),(axs[1],[1,0,0],[value('female_anchor_x'),0,0],(1,2))]:
    sec=adapter.section(plane_origin=origin,plane_normal=normal);assert sec is not None
    for line in sec.discrete:ax.plot(line[:,plane[0]],line[:,plane[1]],color='#285c79',linewidth=2)
    ax.axhline(face,color='#b23930',linestyle='--');ax.set_ylim(face-10,face+38);ax.set_aspect('equal');ax.grid(alpha=.16)
ax=axs[0];ax.add_patch(Rectangle((-10.8,face),21.6,30,facecolor='#edb878',alpha=.22))
ax.add_patch(FancyBboxPatch((-8.5,face),17,28,boxstyle='round,pad=0,rounding_size=.7',facecolor='#cbd0d4',edgecolor='#555555'))
ax.add_patch(Rectangle((-4.7,face),9.4,7,facecolor='white',edgecolor='#555555'))
ax.add_patch(Rectangle((-4,face-7),8,10,facecolor='#919ba3',edgecolor='#333333'))
for x in [-value('female_anchor_x'),value('female_anchor_x')]:
    for z in [value('female_anchor_low'),value('female_anchor_high')]:ax.add_patch(Circle((x,z+face),value('female_anchor_diameter')/2,fill=False,edgecolor='#d5791c',linestyle='--'))
ax.plot([0,0],[face+28,face+36],color='#d5791c',linewidth=4)
ax.annotate('FEMALE cable end held inside insert',xy=(-7,face+15),xytext=(-27,face+33),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.annotate('OEM MALE plug enters from below',xy=(0,face-4),xytext=(-26,face-9),arrowprops={'arrowstyle':'->'},fontsize=9)
ax.set_xlim(-28,31);ax.set_title('Down-facing female socket');ax.set_xlabel('X / mm');ax.set_ylabel('Z / mm')
ax=axs[1];ax.add_patch(Rectangle((-depth/2,face),depth/2+cy+value('female_depth')/2,30,facecolor='#edb878',alpha=.3))
ax.add_patch(Rectangle((cy-4,face),8,28,facecolor='#cbd0d4',edgecolor='#555555'))
ax.annotate('Keyed silicone locks housing\nTrim flush with insert faces',xy=(depth/2-1,face+20),xytext=(10,face+34),arrowprops={'arrowstyle':'->'},fontsize=9)
ax.annotate('Socket opens DOWN at datum Z=0',xy=(cy,face),xytext=(10,face+6),arrowprops={'arrowstyle':'->'},fontsize=9)
ax.set_xlim(-15,34);ax.set_title('Retention-key section');ax.set_xlabel('Y / mm')
fig.suptitle('Dock plug ↑ captured extension female socket in PART A\nBlue: actual print sections | gray hardware is SCHEMATIC, not measured cable housing or verified engagement depth',fontsize=12)
fig.tight_layout();fig.savefig(ROOT/'dock-interface.png',dpi=160);plt.close(fig)
report={'source_sha256':hashlib.sha256(SCAD.read_bytes()).hexdigest(),'printed_parts':2,'parts':parts,
        'rigid_connection_between_parts':False,'matched_z_height_required':False,
        'dock_preview_height_independence':independence,'adapter_insertion_sections':sections,
        'adapter_insertion_envelope_mm':[width,depth,value('insertion_height')],
        'female_socket_face_mm':[0,cy,face],'female_socket_facing_axis':[0,0,-1],'silicone_anchor_holes':4,
        'cradle_clearance_mm':gap,'cradle_seat_above_own_base_mm':value('seat_above_table'),
        'winder':{'built_into_adapter':True,'cores':2,'core_radius_mm':value('winder_core_radius'),
                  'spacing_mm':spacing,'gap_mm':value('winder_gap'),'keeper_radius_mm':value('winder_flange_radius'),
                  'tested_wire_diameter_mm':value('coil_test_diameter'),'sample_loops_checked':2,
                  'length_per_sample_turn_mm':wrap_perimeter,'usable_turns_depend_on_actual_cable_reach':True},
        'collision_checks_empty':True,'physical_fit_verified':False,'electrical_engagement_verified':False,
        'loaded_balance_verified':False,'assembled_preview_is_only_example':True,
        'assumptions':['Estimated 3 mm TPU per face; actual grip not measured.','Oversized silicone-mounted connector pockets; hardware dimensions unmeasured.','Dock envelopes illustrative, not a complete mechanical drawing.','Two sample coils verify space only, not that this cable can spare two full turns.'],
        'openscad_results':results}
(ROOT/'validation.json').write_text(json.dumps(report,indent=2))
print(json.dumps({k:v for k,v in report.items() if k!='openscad_results'},indent=2))
