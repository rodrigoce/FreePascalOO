unit menu_principal_config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, menu_tree_item, ComCtrls, menu_principal_callbacks;

type

  { TMenuPrincipalConfig }

  TMenuPrincipalConfig = class
  private
    FCallBacks: TMenuPrincipalCallBacks;
    FMenuPrincipal: TMenuTreeItem;
    procedure InitCadastros(root: TMenuTreeItem);
    procedure InitMovimentos(root: TMenuTreeItem);
    procedure InitSoftwareHouse(root: TMenuTreeItem);
  public
    destructor Destroy; override;
    procedure InitRootMenus(TreeView: TTreeView);
    procedure ExecuteCallBackOf(node: TTreeNode);
    property MenuPrincipal: TMenuTreeItem read FMenuPrincipal write FMenuPrincipal;
    property CallBacks: TMenuPrincipalCallBacks read FCallBacks write FCallBacks;
  end;

implementation

procedure TMenuPrincipalConfig.InitRootMenus(TreeView: TTreeView);
var
  item: TMenuTreeItem;
begin
  // cria o nó raiz
  MenuPrincipal := TMenuTreeItem.Create;
  MenuPrincipal.Caption := 'root';

  //
  CallBacks := TMenuPrincipalCallBacks.Create;

  // cria os menus principais
  item := MenuPrincipal.AddChild('Cadastros', 0, nil);
  InitCadastros(item);

  item := MenuPrincipal.AddChild('Movimentos', 0, nil);
  InitMovimentos(item);

  item := MenuPrincipal.AddChild('Software House', 0, nil);
  InitSoftwareHouse(item);

  TreeView.Items.Clear;
  MenuPrincipal.WriteOnTreeView(TreeView, MenuPrincipal);
  TreeView.FullExpand;

end;

procedure TMenuPrincipalConfig.ExecuteCallBackOf(node: TTreeNode);
var
  item: TMenuTreeItem;
begin
  item := MenuPrincipal.GetMenuTreeItemOfTreeNode(node, MenuPrincipal);
  if item <> nil then
    if item.CallBack <> nil then
      item.CallBack;
end;

procedure TMenuPrincipalConfig.InitCadastros(root: TMenuTreeItem);
begin
  root.AddChild('Produtos', 1, @CallBacks.ManutencaoProdutos);
  root.AddChild('Usuários', 1, @CallBacks.ManutencaoUsuarios);
  root.AddChild('Fornecedores', 1, @CallBacks.ManutencaoFornecedores);
end;

procedure TMenuPrincipalConfig.InitMovimentos(root: TMenuTreeItem);
begin
  root.AddChild('Compras', 3, @CallBacks.Compras);
end;

procedure TMenuPrincipalConfig.InitSoftwareHouse(root: TMenuTreeItem);
begin
  root.AddChild('DEV Tools', 2, @CallBacks.QueryRunner);
  root.AddChild('Gerador de Código SQL', 2, @CallBacks.GeradorDeCodigoSQL);
  root.AddChild('Gerador de Código Pascal', 2, @CallBacks.GeradorDeCodigoPascal);
  root.AddChild('Testes', 2, @CallBacks.Testes);
end;

destructor TMenuPrincipalConfig.Destroy;
begin
  CallBacks.Free;
  MenuPrincipal.Free;
end;


end.

