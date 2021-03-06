unit gerador_codigo_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, mini_orm,
  ComCtrls;

type

  { TGeradorDeCodigoForm }

  TGeradorDeCodigoForm = class(TForm)
    ListBox1: TListBox;
    memoAlterTable: TMemo;
    memoCreateTable: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private

  public
    class procedure Open;
  end;

var
  GeradorDeCodigoForm: TGeradorDeCodigoForm;

implementation

{$R *.lfm}

{ TGeradorDeCodigoForm }

procedure TGeradorDeCodigoForm.FormShow(Sender: TObject);
var
  table: TORMEntity;
begin
  for table in TORM.EntityList do
  begin
    ListBox1.AddItem(table.EntityClassName, table);
  end;
end;

procedure TGeradorDeCodigoForm.ListBox1Click(Sender: TObject);
begin
  memoCreateTable.Lines.Text := TORM.ToScriptCreate(ListBox1.GetSelectedText);
  memoAlterTable.Lines.Text := TORM.ToScriptAlter(ListBox1.GetSelectedText);
end;

class procedure TGeradorDeCodigoForm.Open;
begin
  Application.CreateForm(TGeradorDeCodigoForm, GeradorDeCodigoForm);
  GeradorDeCodigoForm.ShowModal;
  GeradorDeCodigoForm.Free;
end;

end.

