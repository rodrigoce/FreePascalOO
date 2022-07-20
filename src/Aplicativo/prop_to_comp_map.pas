unit prop_to_comp_map;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Spin, Generics.Collections, TypInfo, Variants;

type

  { TPropToCompMap }

  TPropToCompMapEnum = (ptcmString, ptcmFloat, ptcmDateTime, ptcmBool);

  { TPropToCompMapRec }

  TPropToCompMapItem = class
  private
    FALabel: TLabel;
    FAType: TPropToCompMapEnum;
    FClassPropName: string;
    FFloatEdit: TFloatSpinEdit;
    FMaxLenght: Integer;
    FStringEdit: TEdit;
    FCheckBox: TCheckBox;
  public
    property ClassPropName: string read FClassPropName write FClassPropName;
    property StringEdit: TEdit read FStringEdit write FStringEdit;
    property FloatEdit: TFloatSpinEdit read FFloatEdit write FFloatEdit;
    property CheckBox: TCheckBox read FCheckBox write FCheckBox;
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
    procedure MapBool(ClassPropName: string; CheckBox: TCheckBox);
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

procedure TPropToCompMap.MapBool(ClassPropName: string; CheckBox: TCheckBox);
var
  item: TPropToCompMapItem;
begin
  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.CheckBox := CheckBox;
  item.AType := ptcmBool;

  MapList.Add(item)
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
    end else if item.AType = ptcmBool then
    begin
      item.CheckBox.Checked := GetPropValue(Instance, item.ClassPropName);
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
    end else if item.AType = ptcmBool then
    begin
      SetPropValue(Instance, item.ClassPropName, item.CheckBox.Checked);
    end;
  end;
end;

end.

