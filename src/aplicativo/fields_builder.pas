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
    function LongIntField(Name: string): TLongIntField;
    function StringField(Name: string; Size: Integer): TStringField;
    function FloatField(Name: string): TFloatField;
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

function TFieldsBuilder.LongIntField(Name: string): TLongIntField;
var
  field: TLongintField;
begin
  field := TLongintField.Create(FBufDataSetOwner);
  DefaultProps(field, Name);
  Result := field;
end;

function TFieldsBuilder.StringField(Name: string; Size: Integer): TStringField;
var
  field: TStringField;
begin
  field := TStringField.Create(FBufDataSetOwner);
  field.Size := Size;
  DefaultProps(field, Name);
  Result := field;
end;

function TFieldsBuilder.FloatField(Name: string): TFloatField;
var
  field: TFloatField;
begin
  field := TFloatField.Create(FBufDataSetOwner);
  DefaultProps(field, Name);
  Result := field;
end;

end.

