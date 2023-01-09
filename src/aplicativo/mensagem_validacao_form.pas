unit mensagem_validacao_form;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, StdCtrls, ExtCtrls, validatable, application_types, SysUtils,
  prop_to_comp_map, LazUTF8;

type

  { TMensagemValidacaoForm }

  TMensagemValidacaoForm = class(TForm)
    btOK: TButton;
    Image1: TImage;
    labTitle: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure btOKClick(Sender: TObject);
  private
    function GetLabelCaptionOfClassPropName(ClassPropName: string; PropToCompMap: TPropToCompMap): string;
  public
    class procedure Open(Title: string; ValidatableObj: TValidatable; PropToCompMap: TPropToCompMap; ShowLabCapOnText: Boolean = True);
  end;

var
  MensagemValidacaoForm: TMensagemValidacaoForm;

implementation

{$R *.lfm}

{ TMensagemValidacaoForm }

procedure TMensagemValidacaoForm.btOKClick(Sender: TObject);
begin
  Close;
end;

function TMensagemValidacaoForm.GetLabelCaptionOfClassPropName(ClassPropName: string;
  PropToCompMap: TPropToCompMap): string;
var
  item: TPropToCompMapItem;
begin
  Result := ClassPropName;
  for item in PropToCompMap.MapList do
  begin
     if SameText(item.ClassPropName, ClassPropName) then
     begin
       Result := item.ALabel.Caption;
       break;
     end;
  end;
end;

class procedure TMensagemValidacaoForm.Open(Title: string;
  ValidatableObj: TValidatable; PropToCompMap: TPropToCompMap;
  ShowLabCapOnText: Boolean);
var
  item: TValidationMsgItem;
  i: Integer;
  str, campo: string;
begin
  Application.CreateForm(TMensagemValidacaoForm, MensagemValidacaoForm);
  with MensagemValidacaoForm do
  begin
    labTitle.Caption := Title;
    Application.ProcessMessages;
    Memo1.Clear;

    for item in ValidatableObj.ErrorMessageList do
    begin
      if memo1.Lines.Count > 0 then
        memo1.Lines.Append('');

      str := '';
      campo := '';
      if ShowLabCapOnText then
      begin
        campo := GetLabelCaptionOfClassPropName(item.ClassPropName, PropToCompMap);
        campo := UTF8UpperCase(campo);
      end;

      for i := 0 to item.MsgList.Count -1 do
        str := str + ' ' + Format(item.MsgList[i], [campo]);

      memo1.Append(str);
    end;

    ShowModal;
    Free;
  end;
end;

end.

