unit ComboBoxValue;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TComboBoxValue }

  TComboBoxValue = class(TComboBox)
  private
    FValues : TStringList;
  protected
    function GetSelectedValue : string;
    procedure SetSelectedValue(AValue: string);
    procedure SetValues(const Value: TStringList);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Values: TStringList read FValues write SetValues;
    property SelectedValue : string read GetSelectedValue write SetSelectedValue;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I comboboxvalue_icon.lrs}
  RegisterComponents('Comps',[TComboBoxValue]);
end;

{ TComboBoxValue }

procedure TComboBoxValue.SetValues(const Value: TStringList);
begin
  if Assigned(FValues) then
    FValues.Assign(Value)
  else
    FValues := Value;
end;

constructor TComboBoxValue.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FValues := TStringList.Create;
end;

destructor TComboBoxValue.Destroy;
begin
  inherited Destroy;
  FValues.Free;
end;

function TComboBoxValue.GetSelectedValue: string;
begin
  if (Self.ItemIndex > -1) then
    Result := Self.Values[Self.ItemIndex]
  else
    Result := '';
end;

procedure TComboBoxValue.SetSelectedValue(AValue: string);
begin
  Self.ItemIndex := FValues.IndexOf(AValue);
end;

end.
