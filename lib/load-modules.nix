userConfig: let
  hostname = userConfig.runtime.hostname;
  host = userConfig.hosts.${hostname};
  moduleDirs = (userConfig.moduleDirs or []) ++ (host.moduleDirs or []);
in
  moduleDirs
