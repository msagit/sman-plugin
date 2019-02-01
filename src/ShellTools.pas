unit ShellTools;

interface

procedure Exec(const Command:string);

implementation
uses Windows, ShellApi;

procedure Exec(const Command:string);
begin
  ShellExecute(0, nil, 'cmd.exe', PChar(' /c '+Command), nil, SW_HIDE);
end;
end.
