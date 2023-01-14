unit fields_builder;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, BufDataset;

type

  { TFieldsBuilder }

  TFieldsBuilder = class
  private
    FBufDataSetOwner: TBufDataSet;
    procedure DefaultProps(Field: TField; Name: string);
  public
    constructor Create(FieldsOwner: TBufDataSet);
    function AddLongIntField(Name: string): TLongIntField;
    function AddStringField(Name: string; Size: Integer): TStringField;
    function AddFloatField(Name: string): TFloatField;
  end;

implementation

{ TFieldsBuilder }

procedure TFieldsBuilder.DefaultProps(Field: TField; Name: string);
begin
  Field.FieldName := Name;
  Field.Name := FBufDataSetOwner.Name + Name;
  Field.FieldKind := fkData;
  Field.DataSet := FBufDataSetOwner;
end;

constructor TFieldsBuilder.Create(FieldsOwner: TBufDataSet);
begin
  FBufDataSetOwner := FieldsOwner;
end;

function TFieldsBuilder.AddLongIntField(Name: string): TLongIntField;
var
  field: TLongintField;
begin
  field := TLongintField.Create(FBufDataSetOwner);
  DefaultProps(field, Name);
  Result := field;
end;

function TFieldsBuilder.AddStringField(Name: string; Size: Integer): TStringField;
var
  field: TStringField;
begin
  field := TStringField.Create(FBufDataSetOwner);
  field.Size := Size;
  DefaultProps(field, Name);
  Result := field;
end;

function TFieldsBuilder.AddFloatField(Name: string): TFloatField;
var
  field: TFloatField;
begin
  field := TFloatField.Create(FBufDataSetOwner);
  DefaultProps(field, Name);
  Result := field;
end;

end.

