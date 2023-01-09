unit sql_code_generator_form;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, Dialogs, StdCtrls, mini_orm,
  ComCtrls;

type

  { TSQLCodeGeneratorForm }

  TSQLCodeGeneratorForm = class(TForm)
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
  SQLCodeGeneratorForm: TSQLCodeGeneratorForm;

implementation

{$R *.lfm}

{ TSQLCodeGeneratorForm }

procedure TSQLCodeGeneratorForm.FormShow(Sender: TObject);
var
  table: TORMEntity;
begin
  for table in TORM.EntityList do
  begin
    ListBox1.AddItem(table.EntityClassName, table);
  end;
end;

procedure TSQLCodeGeneratorForm.ListBox1Click(Sender: TObject);
begin
  memoCreateTable.Lines.Text := TORM.ToScriptCreate(ListBox1.GetSelectedText);
  memoAlterTable.Lines.Text := TORM.ToScriptAlter(ListBox1.GetSelectedText);
end;

class procedure TSQLCodeGeneratorForm.Open;
begin
  Application.CreateForm(TSQLCodeGeneratorForm, SQLCodeGeneratorForm);
  SQLCodeGeneratorForm.ShowModal;
  SQLCodeGeneratorForm.Free;
end;

end.

