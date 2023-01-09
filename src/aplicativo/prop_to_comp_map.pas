unit prop_to_comp_map;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Spin, Generics.Collections, TypInfo, Variants,
  StrUtils, ComboBoxValue, EditBtn;

type

  TPropToCompMapEnum = (ptcmEdit, ptcmEditWithNumbersOnly, ptcmMemo, ptcmFloatSpinEdit, ptcmDateEdit, ptcmCheckBox, ptcmCheckBoxCharBool, ptcmCBValue);

  { TPropToCompMapItem }

  TPropToCompMapItem = class
  private
    FALabel: TLabel;
    FAType: TPropToCompMapEnum;
    FClassPropName: string;
    FDateEdit: TDateEdit;
    FFloatSpinEdit: TFloatSpinEdit;
    FMaxLenght: Integer;
    FEdit: TEdit;
    FMemo: TMemo;
    FCheckBox: TCheckBox;
    FCBValue: TComboBoxValue;
    FCharWhenUnchecked: Char;
    FCharWhenChecked: Char;
  public
    property ClassPropName: string read FClassPropName write FClassPropName;
    property Edit: TEdit read FEdit write FEdit;
    property Memo: TMemo read FMemo write FMemo;
    property FloatSpinEdit: TFloatSpinEdit read FFloatSpinEdit write FFloatSpinEdit;
    property DateEdit: TDateEdit read FDateEdit write FDateEdit;
    property CheckBox: TCheckBox read FCheckBox write FCheckBox;
    property CBValue: TComboBoxValue read FCBValue write FCBValue;
    property MaxLength: Integer read FMaxLenght write FMaxLenght;
    property ALabel: TLabel read FALabel write FALabel;
    property AType: TPropToCompMapEnum read FAType write FAType;
    property CharWhenChecked: Char read FCharWhenChecked write FCharWhenChecked;
    property CharWhenUnchecked: Char read FCharWhenUnchecked write FCharWhenUnchecked;
  end;

  { TPropToCompMap }

  TPropToCompMap = class
  private
    FMapList: specialize TList<TPropToCompMapItem>;
  public
    constructor Create;
    destructor Destroy; override;

    // mapeia string para Edit
    procedure MapEdit(ClassPropName: string; Edit: TEdit; MaxLength: Integer; ALabel: TLabel);

    // mapeia string para MapEditWithNumbersOnly
    procedure MapEditWithNumbersOnly(ClassPropName: string; Edit: TEdit; ALabel: TLabel);

    // mapeia string para Memo
    procedure MapMemo(ClassPropName: string; Memo: TMemo; MaxLength: Integer; ALabel: TLabel);

    // mapeia string para ComboBoxValue
    procedure MapCBValue(ClassPropName: string; CBValue: TComboBoxValue; ALabel: TLabel);

    // mapeia double para FloatSpinEdit
    procedure MapFloatSpinEdit(ClassPropName: string; FloatSpinEdit: TFloatSpinEdit; ALabel: TLabel);

    // mapeia Date para DateEdit
    procedure MapDateEdit(ClassPropName: string; DateEdit: TDateEdit; ALabel: TLabel);

    // mapeia booleano para o CheckBox
    procedure MapCheckbox(ClassPropName: string; CheckBox: TCheckBox);

    // mapeia strings 'S'/'N' para booleano no CheckBox
    procedure MapCharCheckbox(ClassPropName: string; CheckBox: TCheckBox; WhenChecked, WhenUnchecked: Char);

    // transfere o valor do objeto para os componentes visuais
    procedure ObjectToComp(Instance: TObject);

    // transfere o valor dos componentes visuais para o objeto
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

procedure TPropToCompMap.MapEdit(ClassPropName: string; Edit: TEdit;
  MaxLength: Integer; ALabel: TLabel);
var
  item: TPropToCompMapItem;
begin
  Edit.MaxLength := MaxLength;

  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.Edit := Edit;
  item.AType := ptcmEdit;
  item.MaxLength := MaxLength;
  item.ALabel := ALabel;

  MapList.Add(item);
end;

procedure TPropToCompMap.MapEditWithNumbersOnly(ClassPropName: string;
  Edit: TEdit; ALabel: TLabel);
var
  item: TPropToCompMapItem;
begin
  Edit.MaxLength := 10;
  Edit.NumbersOnly := True;

  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.Edit := Edit;
  item.AType := ptcmEditWithNumbersOnly;
  item.MaxLength := 10;
  item.ALabel := ALabel;

  MapList.Add(item);
end;

procedure TPropToCompMap.MapMemo(ClassPropName: string; Memo: TMemo;
  MaxLength: Integer; ALabel: TLabel);
var
  item: TPropToCompMapItem;
begin
  Memo.MaxLength := MaxLength;

  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.Memo := Memo;
  item.AType := ptcmMemo;
  item.MaxLength := MaxLength;
  item.ALabel := ALabel;

  MapList.Add(item);

end;

procedure TPropToCompMap.MapCBValue(ClassPropName: string;
  CBValue: TComboBoxValue; ALabel: TLabel);
var
  item: TPropToCompMapItem;
begin
  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.CBValue := CBValue;
  item.AType := ptcmCBValue;
  item.ALabel := ALabel;

  MapList.Add(item);
end;

procedure TPropToCompMap.MapFloatSpinEdit(ClassPropName: string;
  FloatSpinEdit: TFloatSpinEdit; ALabel: TLabel);
var
  item: TPropToCompMapItem;
begin
  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.FloatSpinEdit := FloatSpinEdit;
  item.AType := ptcmFloatSpinEdit;
  item.ALabel := ALabel;

  MapList.Add(item);
end;

procedure TPropToCompMap.MapDateEdit(ClassPropName: string;
  DateEdit: TDateEdit; ALabel: TLabel);
var
  item: TPropToCompMapItem;
begin
  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.DateEdit := DateEdit;
  item.AType := ptcmDateEdit;
  item.ALabel := ALabel;

  MapList.Add(item);
end;

procedure TPropToCompMap.MapCheckbox(ClassPropName: string; CheckBox: TCheckBox);
var
  item: TPropToCompMapItem;
begin
  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.CheckBox := CheckBox;
  item.AType := ptcmCheckBox;

  MapList.Add(item)
end;

procedure TPropToCompMap.MapCharCheckbox(ClassPropName: string;
  CheckBox: TCheckBox; WhenChecked, WhenUnchecked: Char);
var
  item: TPropToCompMapItem;
begin
  item := TPropToCompMapItem.Create;
  item.ClassPropName := ClassPropName;
  item.CheckBox := CheckBox;
  item.AType := ptcmCheckBoxCharBool;
  item.CharWhenChecked := WhenChecked;
  item.CharWhenUnchecked := WhenUnchecked;

  MapList.Add(item)

end;

procedure TPropToCompMap.ObjectToComp(Instance: TObject);
var
  item: TPropToCompMapItem;
begin
  for item in MapList do
  begin
    if item.AType = ptcmEdit then
    begin
      item.Edit.Text := VarToStr(GetPropValue(Instance, item.ClassPropName));
    end else if item.AType = ptcmEditWithNumbersOnly then
    begin
      item.Edit.Text := VarToStr(GetPropValue(Instance, item.ClassPropName));
    end else if item.AType = ptcmMemo then
    begin
      item.Memo.Lines.Text := VarToStr(GetPropValue(Instance, item.ClassPropName));
    end else if item.AType = ptcmFloatSpinEdit then
    begin
      item.FloatSpinEdit.Value := GetPropValue(Instance, item.ClassPropName);
    end else if item.AType = ptcmDateEdit then
    begin
      item.DateEdit.Date := GetPropValue(Instance, item.ClassPropName);
    end else if item.AType = ptcmCheckBox then
    begin
      item.CheckBox.Checked := GetPropValue(Instance, item.ClassPropName);
    end else if item.AType = ptcmCheckBoxCharBool then
    begin
      item.CheckBox.Checked := GetPropValue(Instance, item.ClassPropName) = item.CharWhenChecked;
    end else if item.AType = ptcmCBValue then
    begin
      item.CBValue.SelectedValue := GetPropValue(Instance, item.ClassPropName);
    end;
  end;
end;

procedure TPropToCompMap.CompToObject(Instance: TObject);
var
  item: TPropToCompMapItem;
begin
  for item in MapList do
  begin
    if item.AType = ptcmEdit then
    begin
      SetPropValue(Instance, item.ClassPropName, item.Edit.Text);
    end else if item.AType = ptcmEditWithNumbersOnly then
    begin
      SetPropValue(Instance, item.ClassPropName, IfThen(Trim(item.Edit.Text) = '', '0', item.Edit.Text));
    end else if item.AType = ptcmMemo then
    begin
      SetPropValue(Instance, item.ClassPropName, item.Memo.Lines.Text);
    end else if item.AType = ptcmFloatSpinEdit then
    begin
      SetPropValue(Instance, item.ClassPropName, item.FloatSpinEdit.Value);
    end else if item.AType = ptcmDateEdit then
    begin
      SetPropValue(Instance, item.ClassPropName, item.DateEdit.Date);
    end else if item.AType = ptcmCheckBox then
    begin
      SetPropValue(Instance, item.ClassPropName, item.CheckBox.Checked);
    end else if item.AType = ptcmCheckBoxCharBool then
    begin
      SetPropValue(Instance, item.ClassPropName, IfThen(item.CheckBox.Checked, item.CharWhenChecked, item.CharWhenUnchecked));
    end else if item.AType = ptcmCBValue then
    begin
      SetPropValue(Instance, item.ClassPropName, item.CBValue.SelectedValue);
    end;
  end;
end;

end.

