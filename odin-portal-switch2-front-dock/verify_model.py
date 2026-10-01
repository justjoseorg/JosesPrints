"""Regenerate and verify the ONE-PIECE adapter from OpenSCAD.
Run with: uv run --python 3.11 --with trimesh --with scipy --with networkx --with matplotlib --no-project python verify_model.py
PNG rendering requires a working DISPLAY/OpenGL context. Set OPENSCAD_BIN if needed.
"""
import concurrent.futures, hashlib, json, math, os, re, shutil, subprocess, tempfile
from pathlib import Path
import numpy as np
import trimesh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.collections import PolyCollection

ROOT=Path(__file__).resolve().parent
SCAD=ROOT/'odin_portal_dock.scad'
EXE=os.environ.get('OPENSCAD_BIN') or shutil.which('openscad') or '/opt/data/tools/openscad/runtime/usr/bin/openscad'
TMP=Path(tempfile.mkdtemp(prefix='odin-onepiece-check-'))
source=SCAD.read_text()
def value(name):
    match=re.search(r'^'+re.escape(name)+r'=([0-9.\-]+);',source,re.M)
    assert match,name
    return float(match.group(1))
angle=value('tilt'); gap=value('odin_thickness')+2*value('tpu_per_face')+value('fit_clearance')
depth=value('reference_depth_envelope')-value('insert_depth_clearance')
width=value('reference_insert_width')-value('insert_width_clearance')
results={}

def render(job):
    part,out,png=job
    cmd=[EXE,'--render','-D',f'part="{part}"','-o',str(out)]
    if png:
        cmd.extend(['--autocenter','--viewall','--projection=ortho','--imgsize=1400,1000','--colorscheme=Tomorrow','--camera=0,-30,50,65,0,35,350'])
    cmd.append(str(SCAD))
    p=subprocess.run(cmd,capture_output=True,text=True)
    empty='Current top level object is empty.' in p.stderr
    check=part.endswith('_check')
    assert (p.returncode==1 and empty) if check else p.returncode==0, (part,p.returncode,p.stderr)
    print(part,'PASS',('empty intersection' if check else str(out.name)),flush=True)
    return part,{'exit_code':p.returncode,'expected_empty_intersection':empty,'log':p.stderr}

jobs=[('adapter',ROOT/'adapter.stl',False),('assembled',ROOT/'preview.png',True),
      ('adapter',ROOT/'print-orientation.png',True),('cable_check',TMP/'cable.stl',False),
      ('dock_clearance_check',TMP/'dock.stl',False),('device_clearance_check',TMP/'device.stl',False)]
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as ex:
    for part,result in ex.map(render,jobs):
        results.setdefault(part,[]).append(result)

mesh=trimesh.load_mesh(ROOT/'adapter.stl',process=True)
assert mesh.is_watertight and mesh.is_volume
assert len(mesh.split())==1,'Adapter must be exactly ONE connected printed solid'
assert mesh.bounds[0,2]>=-1e-4,'Print pose must not fall below bed'
# Undo print pose for dimension and route diagrams.
assembled=mesh.copy(); assembled.apply_translation([0,0,-depth/2])
assembled.apply_transform(trimesh.transformations.rotation_matrix(math.pi/2,[1,0,0]))
# Verify actual insertion envelope at multiple heights, not just total bounds.
sections=[]
for h in (5,15,35,49):
    cut=assembled.section(plane_origin=[0,0,h],plane_normal=[0,0,1])
    assert cut is not None
    # Other front cradle material can share a height; filter to the docking slot.
    vertices=cut.vertices[np.abs(cut.vertices[:,1])<=depth/2+1e-3]
    assert len(vertices)>0
    bounds=np.array([vertices.min(axis=0),vertices.max(axis=0)])
    assert bounds[0,0]>=-width/2-1e-3 and bounds[1,0]<=width/2+1e-3
    assert bounds[0,1]>=-depth/2-1e-3 and bounds[1,1]<=depth/2+1e-3
    sections.append({'height_mm':h,'bounds_mm':bounds.tolist()})

# Side diagram: real adapter projection, clearly illustrative dock/handheld.
fig,ax=plt.subplots(figsize=(12,9))
ax.add_collection(PolyCollection(assembled.triangles[:,:,[1,2]],facecolor='#416b84',edgecolor='#34566a',linewidth=.12))
from matplotlib.patches import Rectangle,Polygon
for y,w in [(-25,17),(8,18)]:
    ax.add_patch(Rectangle((y,-55),w,105,facecolor='#bbbbbb',alpha=.4,edgecolor='#555555'))
a=math.radians(angle); sy=value('seat_y'); sz=value('seat_height')
# Transform device envelope corners in Y/Z; no decorative product reconstruction.
def yz(y,z): return (sy+y*math.cos(a)+z*math.sin(a),sz-y*math.sin(a)+z*math.cos(a))
height=value('odin_height')+6
corners=[yz(1,0),yz(gap-1,0),yz(gap-1,height),yz(1,height)]
ax.add_patch(Polygon(corners,facecolor='#6cb5bd',alpha=.24,edgecolor='#247985'))
# Lay-in cable and loose, accessible return loop below cradle.
r=value('cable_bend_radius'); cy=value('female_center_y')
z=value('insertion_height')+4+value('channel_floor')+value('wire_diameter_allowance')/2
arc=np.linspace(0,math.pi/2,50)
column=value('bridge_front')+4; front_r=value('front_bend_radius')
route_y=[cy,cy]+list(cy-r+r*np.cos(arc))+[column+front_r]+list(column+front_r-front_r*np.sin(arc))
route_z=[20,z-r]+list(z-r+r*np.sin(arc))+[z]+list(z-front_r+front_r*np.cos(arc))
holder_height=value('male_height')+value('housing_floor'); mid=gap/2
outlet=np.array(yz(mid,-holder_height)); direction=np.array([math.sin(a),math.cos(a)])
approach=outlet-8*direction; column=value('bridge_front')+4
loop_r=(column-approach[0])/2; loop_c=(column+approach[0])/2
u=np.linspace(0,math.pi,50)
route_y.extend([column]+list(loop_c+loop_r*np.cos(u))+[outlet[0]])
route_z.extend([approach[1]]+list(approach[1]-loop_r*np.sin(u))+[outlet[1]])
ax.plot(route_y,route_z,color='#ee8526',linewidth=3,label='Cable route and accessible slack loop')
ax.annotate('ONE PRINTED PIECE\nOdin cradle + integral USB-C male pocket',xy=(-64,63),xytext=(-125,117),arrowprops={'arrowstyle':'->'},fontsize=11)
ax.annotate('Insert slides into dock slot\n199 × 13.8 mm, 50 mm to stop',xy=(0,22),xytext=(22,87),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.annotate('Existing Nintendo dock\n(gray walls are illustrative)',xy=(16,-25),xytext=(21,-40),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.annotate('Integral USB-C female pocket\nSilicone-adjusted alignment',xy=(-1.8,8),xytext=(-126,-35),arrowprops={'arrowstyle':'->'},fontsize=10)
ax.set_xlim(-135,105);ax.set_ylim(-65,177);ax.set_aspect('equal');ax.grid(alpha=.15)
ax.set_xlabel('Front ← Y → rear / mm');ax.set_ylabel('Z / mm relative to insert bottom')
ax.set_title('One-piece Switch 2 → Odin 2 Portal adapter\nCyan: official body dimensions + estimated TPU allowance',fontsize=14)
ax.legend(loc='lower right',fontsize=8);fig.tight_layout();fig.savefig(ROOT/'placement.png',dpi=150);plt.close(fig)

report={'source_sha256':hashlib.sha256(SCAD.read_bytes()).hexdigest(),
        'adapter_stl_sha256':hashlib.sha256((ROOT/'adapter.stl').read_bytes()).hexdigest(),
        'printed_parts':1,'connected_solids':1,'watertight':True,'positive_volume':True,
        'print_dimensions_mm':mesh.extents.tolist(),'assembled_bounds_mm':assembled.bounds.tolist(),
        'volume_mm3':float(mesh.volume),'triangles':len(mesh.faces),
        'insertion_envelope_mm':[width,depth,value('insertion_height')],
        'insertion_sections':sections,'cradle_depth_clearance_mm':gap,
        'cable_test_diameter_mm':6,'cable_route_positive_volume_collision':False,
        'illustrative_dock_walls_positive_volume_collision':False,
        'odin_tpu_envelope_positive_volume_collision':False,
        'device_check_seat_contact_exclusion_mm':value('eps'),
        'physical_fit_verified':False,
        'assumptions':['TPU allowance 3 mm per face, not measured.','Cable housing pockets intentionally oversized for silicone adjustment.','Dock wall envelopes illustrative, not a full measured Nintendo dock.','Reference STL is nominal original; user previously removed material in their printed copy.'],
        'openscad_results':results}
(ROOT/'validation.json').write_text(json.dumps(report,indent=2))
print(json.dumps({k:v for k,v in report.items() if k!='openscad_results'},indent=2))
