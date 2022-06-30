unit grid_configurator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DBGrids, BufDataset, Graphics;

type

  { TGridCofingurator }

  TGridCofingurator = class
  private
    FOrderedFieldName: string;
    FOrderedDirection: string;
    FDBGrid: TDBGrid;
    procedure _SetOrderedColumn(FieldName: string);
    procedure GridTitleClick(Column: TColumn);
  public
    function WithGrid(Grid: TDBGrid): TGridCofingurator;
    function SetDefaultProps: TGridCofingurator;
    function AddColumn(FieldName, Title: string; Width: Integer; DisplayFormat: string = ''): TGridCofingurator;
    function AddOrderAbility: TGridCofingurator;
    function SetOrderedColumn(FieldName: string): TGridCofingurator;
  end;

implementation

{ TGridCofingurator }

procedure TGridCofingurator._SetOrderedColumn(FieldName: string);
var
  i: Integer;
begin
  if (FOrderedFieldName = FieldName) and (FOrderedDirection = '') then
    FOrderedDirection := ' DESC'
  else
    FOrderedDirection := '';

  if FDBGrid.DataSource.DataSet is TBufDataset then
  begin
    FOrderedFieldName := FieldName;
    (FDBGrid.DataSource.DataSet as TBufDataset).IndexFieldNames := FOrderedFieldName + FOrderedDirection;
  end;

  for i := 0 to FDBGrid.Columns.Count -1 do
    FDBGrid.Columns[i].Title.Font.Color := clDefault;

  FDBGrid.Columns.ColumnByFieldname(FieldName).Title.Font.Color := clBlue;
end;

procedure TGridCofingurator.GridTitleClick(Column: TColumn);
begin
  _SetOrderedColumn(Column.FieldName);
end;

function TGridCofingurator.WithGrid(Grid: TDBGrid): TGridCofingurator;
begin
  FDBGrid := Grid;
  Result := Self;
end;

function TGridCofingurator.SetDefaultProps: TGridCofingurator;
begin
  FDBGrid.Options := [dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgDisableDelete, dgDisableInsert, dgRowHighlight, dgDblClickAutoSize];
  FDBGrid.AutoEdit := False;
  Result := Self;
end;

function TGridCofingurator.AddColumn(FieldName, Title: string; Width: Integer;
  DisplayFormat: string): TGridCofingurator;
var
  col: TColumn;
begin
  col := FDBGrid.Columns.Add;

  col.Title.Caption := Title;
  col.FieldName :=  FieldName;
  col.Width := Width;
  col.DisplayFormat := DisplayFormat;

  Result := Self;
end;

function TGridCofingurator.AddOrderAbility: TGridCofingurator;
begin
  FDBGrid.OnTitleClick := @GridTitleClick;
  FDBGrid.Options := FDBGrid.Options + [dgHeaderHotTracking];

  Result := Self;
end;

function TGridCofingurator.SetOrderedColumn(FieldName: string
  ): TGridCofingurator;
begin
  _SetOrderedColumn(FieldName);

  Result := Self;
end;

end.

