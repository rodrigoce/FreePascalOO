unit grid_configurator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DBGrids, BufDataset;

type

  { TGridCofingurator }

  TGridCofingurator = class
    FCurrentGrid: TDBGrid;
    procedure GridTitleClick(Column: TColumn);
  public
    function WithGrid(Grid: TDBGrid): TGridCofingurator;
    function SetDefaultProps: TGridCofingurator;
    function AddColumn(FieldName, Title: string; Width: Integer; DisplayFormat: string = ''): TGridCofingurator;
    function AddOrderAbility: TGridCofingurator;
  end;

implementation

{ TGridCofingurator }

procedure TGridCofingurator.GridTitleClick(Column: TColumn);
begin
  if FCurrentGrid.DataSource.DataSet is TBufDataset then
    (FCurrentGrid.DataSource.DataSet as TBufDataset).IndexFieldNames := Column.FieldName;
end;

function TGridCofingurator.WithGrid(Grid: TDBGrid): TGridCofingurator;
begin
  FCurrentGrid := Grid;
  Result := Self;
end;

function TGridCofingurator.SetDefaultProps: TGridCofingurator;
begin
  FCurrentGrid.Options := [dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgDisableDelete, dgDisableInsert, dgRowHighlight, dgDblClickAutoSize];
  FCurrentGrid.AutoEdit := False;
  Result := Self;
end;

function TGridCofingurator.AddColumn(FieldName, Title: string; Width: Integer;
  DisplayFormat: string): TGridCofingurator;
var
  col: TColumn;
begin
  col := FCurrentGrid.Columns.Add;

  col.Title.Caption := Title;
  col.FieldName :=  FieldName;
  col.Width := Width;
  col.DisplayFormat := DisplayFormat;

  Result := Self;
end;

function TGridCofingurator.AddOrderAbility: TGridCofingurator;
begin
  FCurrentGrid.OnTitleClick := @GridTitleClick;

  Result := Self;
end;

end.

