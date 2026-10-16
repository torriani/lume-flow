const {parentPort,workerData}=require('node:worker_threads');
const {Store}=require('./store.cjs');const {importHistory}=require('./import-history.cjs');
let store;try{store=new Store(workerData.destination);parentPort.postMessage({ok:true,result:importHistory(store,workerData.source)});}catch(e){parentPort.postMessage({ok:false,error:e.message});}finally{store?.close();}
