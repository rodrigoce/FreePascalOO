unit grid_configurator;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, DBGrids, BufDataset, Graphics;

type

  { TGridConfigurator }

  TGridConfigurator = class
  private
    FOrderedFieldName: string;
    FOrderedDirection: string;
    FDBGrid: TDBGrid;
    procedure _SetOrderedColumn(FieldName: string);
    procedure GridTitleClick(Column: TColumn);
  public
    function WithGrid(Grid: TDBGrid): TGridConfigurator;
    function SetDefaultProps: TGridConfigurator;
    function AddColumn(FieldName, Title: string; Width: Integer; DisplayFormat: string = ''): TGridConfigurator;
    function AddOrderAbility: TGridConfigurator;
    function SetOrderedColumn(FieldName: string): TGridConfigurator;
  end;

implementation

{ TGridConfigurator }

procedure TGridConfigurator._SetOrderedColumn(FieldName: string);
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

procedure TGridConfigurator.GridTitleClick(Column: TColumn);
begin
  _SetOrderedColumn(Column.FieldName);
end;

function TGridConfigurator.WithGrid(Grid: TDBGrid): TGridConfigurator;
begin
  FDBGrid := Grid;
  Result := Self;
end;

function TGridConfigurator.SetDefaultProps: TGridConfigurator;
begin
  FDBGrid.Options := [dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgDisableDelete, dgDisableInsert, dgRowHighlight, dgDblClickAutoSize, dgAnyButtonCanSelect];
  FDBGrid.AutoEdit := False;
  Result := Self;
end;

function TGridConfigurator.AddColumn(FieldName, Title: string; Width: Integer;
  DisplayFormat: string): TGridConfigurator;
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

function TGridConfigurator.AddOrderAbility: TGridConfigurator;
begin
  FDBGrid.OnTitleClick := @GridTitleClick;
  FDBGrid.Options := FDBGrid.Options + [dgHeaderHotTracking];

  Result := Self;
end;

function TGridConfigurator.SetOrderedColumn(FieldName: string
  ): TGridConfigurator;
begin
  _SetOrderedColumn(FieldName);

  Result := Self;
end;

end.

