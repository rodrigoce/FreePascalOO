unit menu_principal_callbacks;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, produto_man_form, gerador_codigo_form, query_runner_form;

type

  { TMenuPrincipalCallBacks }

  TMenuPrincipalCallBacks = class
  public
    procedure ManutencaoProdutos;
    procedure GeradorDeCodigos;
    procedure QueryRunner;
  end;

implementation

{ TMenuPrincipalCallBacks }

procedure TMenuPrincipalCallBacks.ManutencaoProdutos;
begin
  TProdutoManForm.OpenFeature;
end;

procedure TMenuPrincipalCallBacks.GeradorDeCodigos;
begin
  Application.CreateForm(TGeradorDeCodigoForm, GeradorDeCodigoForm);
  GeradorDeCodigoForm.ShowModal;
  GeradorDeCodigoForm.Free;
end;

procedure TMenuPrincipalCallBacks.QueryRunner;
begin
   TQueryRunnerForm.OpenFeature;
end;

end.

