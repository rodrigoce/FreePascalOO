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
  Forms, memdslaz, sdflaz, lazcontrols, conexao_dm, dal_base, entity_base,
  gerador_codigo_form, mini_orm,
menu_principal_form, produto_dal, produto_entity,
  usuario_entity, produto_man_form, application_functions, application_docs,
  produto_cad_form, query_runner_form, log_sql_form, application_delegates,
  application_types, validatable, bll_base, validator_base, produto_bll, 
produto_validator, images_dm, menu_tree_item, menu_principal_config,
menu_principal_callbacks, mensagem_validacao_form, prop_to_comp_map, 
grid_configurator;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title := 'Aplicativo';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TImagesDM, ImagesDM);
  Application.CreateForm(TConexaoDM, ConexaoDM);
  Application.CreateForm(TMenuPrincipalForm, MenuPrincipalForm);
  Application.Run;
end.

