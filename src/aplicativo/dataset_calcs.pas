unit dataset_calcs;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, DB;

type

  { TDatasetCalcs }

  TDatasetCalcs = class
    public
      function SumColumn(Dataset: TDataSet; ColumnName: string): Double;
  end;

implementation

{ TDatasetCalcs }

function TDatasetCalcs.SumColumn(Dataset: TDataSet; ColumnName: string): Double;
var
  bk: TBookMark;
begin
  bk := Dataset.GetBookmark;
  Result := 0;

  Dataset.DisableControls;
  Dataset.First;
  while not Dataset.EOF do
  begin
    Result := Result + Dataset.FieldByName(ColumnName).AsFloat;

    Dataset.Next;
  end;
  Dataset.GotoBookmark(bk);
  Dataset.FreeBookmark(bk);
  Dataset.EnableControls;
end;

end.

