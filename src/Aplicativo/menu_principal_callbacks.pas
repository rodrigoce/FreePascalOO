unit menu_principal_callbacks;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, produto_man_form;

type

  { TMenuPrincipalCallBacks }

  TMenuPrincipalCallBacks = class
  public
    procedure ManutencaoProdutos;
  end;

implementation

{ TMenuPrincipalCallBacks }

procedure TMenuPrincipalCallBacks.ManutencaoProdutos;
begin
  TProdutoManForm.OpenFeature;
end;

end.

