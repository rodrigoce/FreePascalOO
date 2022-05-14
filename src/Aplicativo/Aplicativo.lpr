program Aplicativo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, memdslaz, sdflaz, conexao_dm, dal_base, entity_base,
  gerador_codigo_form, mini_orm, principal_form, produto_dal, produto_entity,
  usuario_entity, produto_man_form, funcoes, documentacao, produto_cad_form;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Aplicativo';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMenuPrincipalForm, MenuPrincipalForm);
  Application.CreateForm(TConexaoDM, ConexaoDM);
  Application.Run;
end.

