unit menu_tree_item;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections, ComCtrls, application_delegates,
  Dialogs;

type

  { TMenuTreeItem }

  TMenuTreeItem = class
  private
    FCallBack: TNoParam;
    FCaption: string;
    FChildren: specialize TList<TMenuTreeItem>;
    FImageIndex: Integer;
    FParent: TMenuTreeItem;
    FTreeNode: TTreeNode;
    procedure RecursiveWriteOnTreeView(TreeView: TTreeView; Menu: TMenuTreeItem; ParentTreeNode: TTreeNode);
  public
    constructor Create;
    destructor Destroy; override;
    // o RootMenu não é colocado no TreeView
    procedure WriteOnTreeView(TreeView: TTreeView; RootMenu: TMenuTreeItem);
    function AddChild(AText: string; AImageIndex: Integer; ACallBack: TNoParam): TMenuTreeItem;
    function GetMenuTreeItemOfTreeNode(node: TTreeNode; RootMenu: TMenuTreeItem): TMenuTreeItem;
    //
    property Caption: string read FCaption write FCaption;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property Parent: TMenuTreeItem read FParent write FParent;
    // armazena quem foi o nó criado para esse menu
    property TreeNode: TTreeNode read FTreeNode write FTreeNode;
    property Children: specialize TList<TMenuTreeItem> read FChildren;
    property CallBack: TNoParam read FCallBack write FCallBack;
  end;

implementation

{ TMenuTreeItem }

function TMenuTreeItem.AddChild(AText: string; AImageIndex: Integer;
  ACallBack: TNoParam): TMenuTreeItem;
var
  item: TMenuTreeItem;
begin
  item := TMenuTreeItem.Create;
  item.Caption := AText;
  item.ImageIndex := AImageIndex;
  item.CallBack := ACallBack;

  FChildren.Add(item);

  Result := item;
end;

function TMenuTreeItem.GetMenuTreeItemOfTreeNode(node: TTreeNode;
  RootMenu: TMenuTreeItem): TMenuTreeItem;
var
  item: TMenuTreeItem;
begin
  Result := nil;

  if RootMenu.TreeNode = node then
    Result := RootMenu
  else
    for item in RootMenu.Children do
    begin
      Result := GetMenuTreeItemOfTreeNode(node, item);
      if Result <> nil then
        break;
    end;
end;

procedure TMenuTreeItem.RecursiveWriteOnTreeView(TreeView: TTreeView;
  Menu: TMenuTreeItem; ParentTreeNode: TTreeNode);
var
  node: TTreeNode;
  menuItem: TMenuTreeItem;
begin
  node := TreeView.Items.AddChild(ParentTreeNode, Menu.Caption);
  node.ImageIndex := Menu.ImageIndex;
  node.SelectedIndex := Menu.ImageIndex;
  node.Data := @Menu;

  Menu.TreeNode := node;

  for menuItem in Menu.Children do
    RecursiveWriteOnTreeView(TreeView, menuItem, node);
end;

constructor TMenuTreeItem.Create;
begin
  FChildren := specialize TList<TMenuTreeItem>.Create;
end;

destructor TMenuTreeItem.Destroy;
var
  item: TMenuTreeItem;
begin
  for item in FChildren do
    item.Free;

  inherited Destroy;
end;

procedure TMenuTreeItem.WriteOnTreeView(TreeView: TTreeView;
  RootMenu: TMenuTreeItem);
var
  menuItem: TMenuTreeItem;
begin
  for menuItem in RootMenu.Children do
  begin
    RecursiveWriteOnTreeView(TreeView, menuItem, nil);
  end;
end;



end.

