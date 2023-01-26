unit menu_principal_callbacks;

{$mode ObjFPC}{$H+}

interface

uses
  fornecedor_man_form, compra_man_form;

type

  { TMenuPrincipalCallBacks }

  TMenuPrincipalCallBacks = class
  public
    procedure ManutencaoProdutos;
    procedure ManutencaoUsuarios;
    procedure ManutencaoFornecedores;

    procedure Compras;

    procedure GeradorDeCodigoSQL;
    procedure GeradorDeCodigoPascal;
    procedure QueryRunner;
  end;

implementation

uses pascal_code_generator_form, produto_man_form, usuario_man_form,
  sql_code_generator_form, dev_tools_form;

{ TMenuPrincipalCallBacks }

procedure TMenuPrincipalCallBacks.ManutencaoProdutos;
begin
  TProdutoManForm.Open(False);
end;

procedure TMenuPrincipalCallBacks.ManutencaoUsuarios;
begin
  TUsuarioManForm.Open(False);
end;

procedure TMenuPrincipalCallBacks.ManutencaoFornecedores;
begin
  TFornecedorManForm.Open(False);
end;

procedure TMenuPrincipalCallBacks.Compras;
begin
  TCompraManForm.Open(False);
end;

procedure TMenuPrincipalCallBacks.GeradorDeCodigoSQL;
begin
  TSQLCodeGeneratorForm.Open;
end;

procedure TMenuPrincipalCallBacks.GeradorDeCodigoPascal;
begin
  TPascalCodeGeneratorForm.Open;
end;

procedure TMenuPrincipalCallBacks.QueryRunner;
begin
   TDevToolsForm.Open;
end;

end.

