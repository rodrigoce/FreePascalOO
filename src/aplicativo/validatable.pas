unit validatable;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, application_types, Generics.Collections, TypInfo;

type

  { TValidatable }

  // Classe par ser herdade em Entities, DTOs ou Models
  TValidatable = class
    private
      FErrorMessageList: specialize TList<TValidationMsgItem>;
      FPropsNamesList: TStringList;
      procedure PopulatePropsNames;
      function GetIsValid: Boolean;
    public
      constructor Create;
      destructor Destroy; override;

      procedure AddErrorValidationMsg(ClassPropName, Message: string);
      procedure ClearErrorMessages;
      function ClassPropNameExists(ClassFieldName: string): Boolean;
      function GetAllRawErrorMessages: string;
      property ErrorMessageList: specialize TList<TValidationMsgItem> read FErrorMessageList;
      property PropsNamesList: TStringList read FPropsNamesList;
      property IsValid: Boolean read GetIsValid;
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

function TValidatable.GetIsValid: Boolean;
begin
  Result := FErrorMessageList.Count = 0;
end;

function TValidatable.ClassPropNameExists(ClassFieldName: string): Boolean;
begin
  Result := FPropsNamesList.IndexOf(ClassFieldName) > -1;
end;

procedure TValidatable.AddErrorValidationMsg(ClassPropName, Message: string);
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
  if ClassPropName <> '' then
    if not ClassPropNameExists(ClassPropName) then
      raise Exception.Create('A classe do tipo ' + Self.ClassName + ' não tem o campo ' + ClassPropName);

  added := False;
  for item in FErrorMessageList do
  begin
    if item.ClassPropName = ClassPropName then
      AddErrorMsg(item)
  end;

  if not added then
  begin
    item := TValidationMsgItem.Create;
    item.ClassPropName := ClassPropName;
    AddErrorMsg(item);
    FErrorMessageList.Add(item);
  end;
end;

procedure TValidatable.ClearErrorMessages;
var
  item: TValidationMsgItem;
begin
  for item in FErrorMessageList do
  begin
    item.MsgList.Free;
    item.Free;
  end;

  FErrorMessageList.Clear;
end;

function TValidatable.GetAllRawErrorMessages: string;
var
  item: TValidationMsgItem;
  s: string;
begin
  s := '';
  for item in FErrorMessageList do
  begin
    s := s + item.ClassPropName + ': ' + item.MsgList.Text + LineEnding;
  end;
  Result := s;
end;

constructor TValidatable.Create;
begin
  inherited;
  FErrorMessageList := specialize TList<TValidationMsgItem>.Create;
  FPropsNamesList := TStringList.Create;
  PopulatePropsNames;
end;

destructor TValidatable.Destroy;
begin
  ClearErrorMessages;

  FErrorMessageList.Free;

  FPropsNamesList.Free;

  inherited Destroy;
end;

end.

