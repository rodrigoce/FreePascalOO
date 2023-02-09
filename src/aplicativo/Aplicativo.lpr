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
  Forms, rxnew, rx, memdslaz, sdflaz, lazcontrols, tachartlazaruspkg,
  dal_base, entity_base, sql_code_generator_form, mini_orm,
  menu_principal_form, produto_dal, produto_entity, usuario_entity,
  produto_man_form, application_functions, application_docs, produto_cad_form,
  dev_tools_form, application_delegates, application_types, validatable,
  bll_base, validator_base, produto_bll, produto_validator, images_dm,
  menu_tree_item, menu_principal_config, menu_principal_callbacks,
  mensagem_validacao_form, prop_to_comp_map, grid_configurator, produto_filter,
  filter_composer, produto_filter_validator, entity_log_form,
  pascal_code_generator_form, usuario_filter, usuario_filter_validator,
  usuario_dal, usuario_validator, usuario_bll, usuario_change_pass_form,
  usuario_man_form, BCrypt, usuario_login_form, usuario_login,
  usuario_login_validator, application_session, usuario_change_password,
  usuario_change_password_validator, usuario_cad_form, fornecedor_validator,
  fornecedor_man_form, fornecedor_filter_validator, fornecedor_filter,
  fornecedor_entity, fornecedor_dal, fornecedor_cad_form, fornecedor_bll,
  compra_validator, compra_man_form, compra_filter_validator, compra_filter,
  compra_entity, compra_dal, compra_cad_form, compra_bll, compra_item_entity,
  compra_item_dal, fields_builder, dataset_calcs, db_context, tests_form, TODO;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title := 'Aplicativo';
  Application.Scaled := True;
  Application.Initialize;
  TApplicationSession.InitEnvironment;
  Application.CreateForm(TImagesDM, ImagesDM);
  Application.CreateForm(TMenuPrincipalForm, MenuPrincipalForm);
  Application.CreateForm(TTestesForm, TestesForm);
  Application.Run;
end.

