unit prop_to_comp_map;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Spin, Generics.Collections, TypInfo, Variants;

type

  { TPropToCompMap }

  TPropToCompMapEnum = (ptcmString, ptcmFloat, ptcmDateTime);

  { TPropToCompMapRec }

  TPropToCompMapItem = class
  private
    FALabel: TLabel;
    FAType: TPropToCompMapEnum;
    FClassPropName: string;
    FFloatEdit: TFloatSpinEdit;
    FMaxLenght: Integer;
    FStringEdit: TEdit;
  public
    property ClassPropName: string read FClassPropName write FClassPropName;
    property StringEdit: TEdit read FStringEdit write FStringEdit;
    property FloatEdit: TFloatSpinEdit read FFloatEdit write FFloatEdit;
    property MaxLength: Integer read FMaxLenght write FMaxLenght;
    property ALabel: TLabel read FALabel write FALabel;
    property AType: TPropToCompMapEnum read FAType write FAType;

  end;

  TPropToCompMap = class
  private
    FMapList: specialize TList<TPropToCompMapItem>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure MapString(ClassPropName: string; Edit: TEdit; MaxLength: Integer; ALabel: TLabel);
    procedure MapFloat(ClassPropName: string; FloatSpinEdit: TFloatSpinEdit; ALabel: TLabel);
    procedure ObjectToComp(Instance: TObject);
    procedure CompToObject(Instance: TObject);

    property MapList: specialize TList<TPropToCompMapItem> read FMapList write FMapList;
  end;

implementation

{ TPropToCompMap }

constructor TPropToCompMap.Create;
begin
  MapList := specialize TList<TPropToCompMapItem>.Create;
end;

destructor TPropToCompMap.Destroy;
var
  item: TPropToCompMapItem;
begin
  for item in MapList do
    item.Free;

  inherited Destroy;
end;

procedure TPropToCompMap.MapString(ClassPropName: string; Edit: TEdit;
  MaxLength: Integer; ALabel: TLabel);
var
  item: TPropToCompMapItem;
begin
  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.StringEdit := Edit;
  item.AType := ptcmString;
  item.MaxLength := MaxLength;
  item.ALabel := ALabel;

  MapList.Add(item);
end;

procedure TPropToCompMap.MapFloat(ClassPropName: string;
  FloatSpinEdit: TFloatSpinEdit; ALabel: TLabel);
var
  item: TPropToCompMapItem;
begin
  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.FloatEdit := FloatSpinEdit;
  item.AType := ptcmFloat;
  item.ALabel := ALabel;

  MapList.Add(item);
end;

procedure TPropToCompMap.ObjectToComp(Instance: TObject);
var
  item: TPropToCompMapItem;
begin
  for item in MapList do
  begin
    if item.AType = ptcmString then
    begin
      item.StringEdit.Text := VarToStr(GetPropValue(Instance, item.ClassPropName));
      item.StringEdit.MaxLength := item.MaxLength;
    end else if item.AType = ptcmFloat then
    begin
      item.FloatEdit.Value := GetPropValue(Instance, item.ClassPropName);
    end;
  end;
end;

procedure TPropToCompMap.CompToObject(Instance: TObject);
var
  item: TPropToCompMapItem;
begin
  for item in MapList do
  begin
    if item.AType = ptcmString then
    begin
      SetPropValue(Instance, item.ClassPropName, item.StringEdit.Text);
    end else if item.AType = ptcmFloat then
    begin
      SetPropValue(Instance, item.ClassPropName, item.FloatEdit.Value);
    end;
  end;
end;

end.

