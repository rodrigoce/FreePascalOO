unit mensagem_validacao_form;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, StdCtrls, ExtCtrls, validatable, application_types, Classes, SysUtils,
  prop_to_comp_map, LazUTF8;

type

  { TMensagemValidacaoForm }

  TMensagemValidacaoForm = class(TForm)
    Button1: TButton;
    Image1: TImage;
    labTitle: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    function GetLabelCaptionOfClassPropName(ClassPropName: string; PropToCompMap: TPropToCompMap): string;
  public
    class procedure Open(title: string; validatableObj: TValidatable; PropToCompMap: TPropToCompMap);
  end;

var
  MensagemValidacaoForm: TMensagemValidacaoForm;

implementation

{$R *.lfm}

{ TMensagemValidacaoForm }

procedure TMensagemValidacaoForm.Button1Click(Sender: TObject);
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

class procedure TMensagemValidacaoForm.Open(title: string;
  validatableObj: TValidatable; PropToCompMap: TPropToCompMap);
var
  item: TValidationMsgItem;
  i: Integer;
  str: string;
begin
  Application.CreateForm(TMensagemValidacaoForm, MensagemValidacaoForm);
  with MensagemValidacaoForm do
  begin
    labTitle.Caption := title;
    Memo1.Clear;

    for item in validatableObj.ErrorMessageList do
    begin
      if memo1.Lines.Count > 0 then
        memo1.Lines.Append('');

      str := GetLabelCaptionOfClassPropName(item.ClassPropName, PropToCompMap) + ':';
      str := UTF8UpperCase(str);

      for i := 0 to item.MsgList.Count -1 do
        str := str + ' ' + item.MsgList[i];

      memo1.Append(str);
    end;

    ShowModal;
    Free;
  end;
end;

end.

