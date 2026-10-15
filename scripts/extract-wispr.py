"""Importação local autorizada: somente dicionário, estilos e metadados de uso.
Não lê texto ditado, áudio, screenshots, contexto de campos, URLs ou credenciais.
"""
import sqlite3,json,pathlib,sys,datetime
source=pathlib.Path(sys.argv[1]) if len(sys.argv)>1 else pathlib.Path.home()/'Library/Application Support/Wispr Flow'
out=pathlib.Path(sys.argv[2]) if len(sys.argv)>2 else pathlib.Path('.local/import/wispr.json')
c=sqlite3.connect((source/'flow.sqlite').as_uri()+'?mode=ro',uri=True);c.row_factory=sqlite3.Row
rules=[dict(r) for r in c.execute('SELECT id,phrase,replacement,isSnippet,manualEntry,frequencyUsed FROM Dictionary WHERE coalesce(isDeleted,0)=0')]
usage=[]
for r in c.execute('SELECT transcriptEntityId,timestamp,duration,speechDuration,numWords,numWordsCorrected,numDictionaryReplacements,app,personalizationStyleSettings FROM History'):
 d=dict(r)
 try:d['personalizationStyleSettings']=json.loads(d['personalizationStyleSettings'] or '{}')
 except (ValueError,TypeError):d['personalizationStyleSettings']={}
 usage.append(d)
config=json.loads((source/'config.json').read_text());prefs=config.get('prefs',{}).get('user',{})
styles={k:v for k,v in prefs.get('personalizationStyles',{}).items() if k in ['work','email','personal','other'] and v in ['formal','casual','very_casual','very casual','veryCasual']}
voices={k:{'stylePreference':v.get('stylePreference'),'autoCleanupLevel':v.get('autoCleanupLevel')} for k,v in prefs.get('userVoices',{}).items() if k in ['work','email','personal','other'] and isinstance(v,dict)}
payload={'schema':1,'source':'Wispr Flow local','extracted_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'dictionary':rules,'usage':usage,'styles':styles,'voices':voices,'autoCleanup':prefs.get('autoCleanup',{}).get('level','none')}
out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(payload,ensure_ascii=False));out.chmod(0o600)
print(json.dumps({'dictionary':len(rules),'usage_records':len(usage),'output':str(out)}))
