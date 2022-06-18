unit menu_principal_seed;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, menu_tree_item, ComCtrls, menu_principal_callbacks;

type

  { TMenuPrincipalSeed }

  TMenuPrincipalSeed = class
  private
    FCallBacks: TMenuPrincipalCallBacks;
    procedure InitCadastros(root: TMenuTreeItem);
    procedure InitSoftwareHouse(root: TMenuTreeItem);
  public
    procedure InitRootMenus(MenuTree: TMenuTreeItem; TreeView: TTreeView);
    property CallBacks: TMenuPrincipalCallBacks read FCallBacks write FCallBacks;
  end;

implementation

procedure TMenuPrincipalSeed.InitRootMenus(MenuTree: TMenuTreeItem;
  TreeView: TTreeView);
var
  item: TMenuTreeItem;
begin
  // cria o nó raiz
  MenuTree := TMenuTreeItem.Create;
  MenuTree.Caption := 'root';

  //
  CallBacks := TMenuPrincipalCallBacks.Create;

  // cria os menus principais
  item := MenuTree.AddChild('Cadastros', 0, nil);
  InitCadastros(item);

  item := MenuTree.AddChild('Software House', 0, nil);
  InitSoftwareHouse(item);

  TreeView.Items.Clear;
  MenuTree.WriteOnTreeView(TreeView, MenuTree);
  TreeView.FullExpand;

end;

procedure TMenuPrincipalSeed.InitCadastros(root: TMenuTreeItem);
begin
  root.AddChild('Produtos', 1, @CallBacks.ManutencaoProdutos);
end;

procedure TMenuPrincipalSeed.InitSoftwareHouse(root: TMenuTreeItem);
begin
  root.AddChild('Executor de SQL', 2, nil);
  root.AddChild('Gerador de Código', 2, nil);
end;


end.

