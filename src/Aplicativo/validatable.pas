unit validatable;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, application_types, Generics.Collections, TypInfo;

type

  { TValidatable }
  // classe par ser herdade em Entities, DTOs ou Models
  TValidatable = class
    private
      FErrorMessageList: specialize TList<TValidationMsgItem>;
      FPropsNamesList: TStringList;
      FIsValid: Boolean;
      procedure PopulatePropsNames;
    public
      function ValidateMemberName(ClassFieldName: string): Boolean;
      procedure AddErrorValidationMsg(ClassFieldName, Message: string);
      function GetAllRawErrorMessages: string;
      constructor Create;
      destructor Destroy; override;
      property ErrorMessageList: specialize TList<TValidationMsgItem> read FErrorMessageList;
      property PropsNamesList: TStringList read FPropsNamesList;
      property IsValid: Boolean read FIsValid;
  end;

implementation

{ TValidatable }

procedure TValidatable.PopulatePropsNames;
var
  i: Integer;
  vpTypeInfo: PTypeInfo;
  vPTypeData: PTypeData;
  vPPropList: PPropList;
begin
  vpTypeInfo := PTypeInfo(Self.ClassType.ClassInfo);
  vPTypeData := GetTypeData(vpTypeInfo);

  GetPropList(Self, vPPropList);

  for i := 0 to vPTypeData^.PropCount -1 do
  begin
    FPropsNamesList.Add(vPPropList^[i]^.Name);
  end;
end;

function TValidatable.ValidateMemberName(ClassFieldName: string): Boolean;
begin
  Result := FPropsNamesList.IndexOf(ClassFieldName) > -1;
end;

procedure TValidatable.AddErrorValidationMsg(ClassFieldName, Message: string);
var
  item: TValidationMsgItem;
  added: Boolean;

  procedure AddErrorMsg(item: TValidationMsgItem);
  begin
    if item.MsgList = nil then
      item.MsgList := TStringList.Create;

    item.MsgList.Add(Message);
    added := True;
  end;

begin
  if not ValidateMemberName(ClassFieldName) then
    raise Exception.Create('A classe do tipo ' + Self.ClassName + ' não tem o campo ' + ClassFieldName);

  added := False;
  for item in FErrorMessageList do
  begin
    if item.ClassFieldName = ClassFieldName then
      AddErrorMsg(item)
  end;

  if not added then
  begin
    item := TValidationMsgItem.Create;
    item.ClassFieldName := ClassFieldName;
    AddErrorMsg(item);
    FErrorMessageList.Add(item);
  end;

  FIsValid := False;
end;

function TValidatable.GetAllRawErrorMessages: string;
var
  item: TValidationMsgItem;
  s: string;
begin
  s := '';
  for item in FErrorMessageList do
  begin
    s := s + item.ClassFieldName + ': ' + item.MsgList.Text + LineEnding;
  end;
  Result := s;
end;

constructor TValidatable.Create;
begin
  inherited;
  FErrorMessageList := specialize TList<TValidationMsgItem>.Create;
  FPropsNamesList := TStringList.Create;
  FIsValid := True;
  PopulatePropsNames;
end;

destructor TValidatable.Destroy;
var
  item: TValidationMsgItem;
begin
  for item in FErrorMessageList do
  begin
    item.MsgList.Free;
    item.Free;
  end;

  FErrorMessageList.Free;

  FPropsNamesList.Free;

  inherited Destroy;
end;

end.

