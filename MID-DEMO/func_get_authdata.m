function func_get_authdata()
 path = fileparts(which('TCPclient.py'));
 if count(py.sys.path, path) == 0
     insert(py.sys.path, int32(0), path);
 end
 mod = py.importlib.import_module('TCPclient');
 py.importlib.reload(mod);
 pyout = py.TCPclient.main();
