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
end;

procedure TMenuPrincipalConfig.InitSoftwareHouse(root: TMenuTreeItem);
begin
  root.AddChild('Executor de SQL', 2, @CallBacks.QueryRunner);
  root.AddChild('Gerador de Código', 2, @CallBacks.GeradorDeCodigos);
  root.ADdChild('Log de SQL', 2, @CallBacks.OpenLogSQL);
end;

destructor TMenuPrincipalConfig.Destroy;
begin
  CallBacks.Free;
  MenuPrincipal.Free;
end;


end.

