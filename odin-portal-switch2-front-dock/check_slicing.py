"""Compare native old/current cradle with the SAME automatic-support settings.
Run after verify_model.py. SLICER_BIN overrides PrusaSlicer. No printer-ready
G-code is published: these are generic diagnostics, not your printer profile.
"""
import hashlib,json,os,re,subprocess,tempfile,math
from pathlib import Path
ROOT=Path(__file__).resolve().parent
EXE=os.environ.get('SLICER_BIN','/opt/data/tools/prusaslicer/runtime/usr/bin/prusa-slicer')
BASELINE='dfff88db3b71490f0810f368c6996e7699382bd9'
TMP=Path(tempfile.mkdtemp(prefix='odin-slicing-'))
old=TMP/'old-cradle.stl'
old.write_bytes(subprocess.check_output(['git','show',BASELINE+':odin-portal-switch2-front-dock/cradle.stl'],cwd=ROOT))
version=subprocess.check_output([EXE,'--help'],text=True).splitlines()[0]
settings=['--export-gcode','--layer-height','0.2','--first-layer-height','0.2',
          '--nozzle-diameter','0.4','--filament-diameter','1.75','--perimeters','4',
          '--fill-density','20%','--support-material','--support-material-threshold','45',
          '--dont-support-bridges']
report={'slicer':version,'baseline_commit':BASELINE,'cli_settings':settings,'physical_print_verified':False,
        'note':'Same generic automatic-support diagnostic. Not a tuned printer profile or physical print test.','parts':{}}
for name,stl in [('previous_cradle',old),('redesigned_cradle',ROOT/'cradle.stl')]:
    gcode=TMP/(name+'.gcode')
    p=subprocess.run([EXE,*settings,'-o',str(gcode),str(stl)],capture_output=True,text=True)
    assert p.returncode==0,(name,p.stdout,p.stderr)
    kind='';pos={'X':0.,'Y':0.,'E':0.};relative=False;total=0.;moves=0
    for line in gcode.read_text().splitlines():
        if line.startswith(';TYPE:'):kind=line[6:]
        code=line.split(';',1)[0].strip()
        if code=='M83':relative=True
        if code=='M82':relative=False
        vals={k:float(v) for k,v in re.findall(r'([XYE])(-?\d+(?:\.\d+)?)',code)}
        if code.startswith('G92'):
            pos.update(vals);continue
        if not re.match(r'^G[01]\s',code):continue
        delta=vals.get('E',0) if relative else vals.get('E',pos['E'])-pos['E']
        travel=math.hypot(vals.get('X',pos['X'])-pos['X'],vals.get('Y',pos['Y'])-pos['Y'])
        if 'Support material' in kind and delta>0 and travel>1e-6:total+=delta;moves+=1
        pos.update(vals)
    report['parts'][name]={'stl_sha256':hashlib.sha256(stl.read_bytes()).hexdigest(),
                          'support_filament_mm':total,'support_extrusion_moves':moves,
                          'diagnostic_gcode_path':str(gcode),'exit_code':p.returncode}
    print(name,'support filament mm:',round(total,3),'moves:',moves,flush=True)
before=report['parts']['previous_cradle']['support_filament_mm'];after=report['parts']['redesigned_cradle']['support_filament_mm']
assert before>0 and after<before,(before,after)
report['support_filament_reduction_percent']=100*(before-after)/before
(ROOT/'slicing-validation.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
