program aplicativo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, principal_form, produto_entity, mini_orm,
  dal_base, produto_dal, gerador_codigo_form, usuario_entity,
conexao_dm
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TConexaoDM, ConexaoDM);
  Application.CreateForm(TMenuPrincipalForm, MenuPrincipalForm);
  Application.Run;
end.

