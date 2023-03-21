unit tests_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, Forms, Controls, StdCtrls, DBGrids, Generics.Collections, db_tests,
  fields_builder, grid_configurator, test_base, db_context,
  application_functions, BufDataset, DB, SQLDB, Classes, Dialogs, Math;

type

  { TTestesForm }

  TTestesForm = class(TForm)
    bufTests: TBufDataset;
    btRunTests: TButton;
    ckDontRunTestsWithExceptionsBased: TCheckBox;
    gridTests: TDBGrid;
    dsTests: TDataSource;
    procedure btRunTestsClick(Sender: TObject);
  private
    FDBTests: TDBTests;
    procedure ConfigureGrid;
    procedure RegisterTests;
    procedure ResetTests;
    procedure AfterExecuteItem(const TestNumber: Integer; const TestResult: TTestResult);
  public
    class procedure Open;
  end;

var
  TestesForm: TTestesForm;

implementation

{$R *.lfm}

{ TTestesForm }

procedure TTestesForm.btRunTestsClick(Sender: TObject);
begin
  ResetTests;
  FDBTests.Execute(ckDontRunTestsWithExceptionsBased.Checked);
end;

procedure TTestesForm.ConfigureGrid;
var
  fb: TFieldsBuilder;
  gc: TGridConfigurator;
begin
  fb := TFieldsBuilder.Create(bufTests);
  bufTests.Fields.Clear;
  fb.AddLongIntField('TestNumber');
  fb.AddStringField('Title', 1000);
  fb.AddStringField('Pass', 20);
  fb.AddStringField('Message', 4000);
  bufTests.CreateDataset;
  fb.Free;

  gc := TGridConfigurator.Create;
  gc.WithGrid(gridTests)
    .AddOrderAbility
    .SetDefaultProps
    .AddColumn('TestNumber', 'Número', 80)
    .AddColumn('Title', 'Titulo', 700)
    .AddColumn('Pass', 'Passou?', 120)
    .AddColumn('Message', 'Mesagem', 700);
  gc.Free;
end;

procedure TTestesForm.RegisterTests;
var
  lisfOfTests: specialize TList<TTestItem>;
  itemOfTest: TTestItem;
begin
  FDBTests.RegisterTests;
  FDBTests.TestItemAfterExecute := @AfterExecuteItem;
  lisfOfTests := FDBTests.GetTestList;

  bufTests.Close;
  bufTests.CreateDataset;
  for itemOfTest in lisfOfTests do
  begin
    bufTests.Append;
    bufTests.FieldByName('TestNumber').Value := itemOfTest.TestNumber;
    bufTests.FieldByName('Title').Value := itemOfTest.Title;
    bufTests.FieldByName('Pass').Value := 'NÃO EXECUTADO';
    bufTests.FieldByName('Message').Value := itemOfTest.TestResult.Message;
    bufTests.Post;
  end;

  bufTests.First;
end;

procedure TTestesForm.ResetTests;
begin
  bufTests.DisableControls;
  bufTests.First;
  while not bufTests.EOF do
  begin
    bufTests.Edit;
    bufTests.FieldByName('Pass').Value := 'NÃO EXECUTADO';
    bufTests.FieldByName('Message').Value := '';
    bufTests.Post;
    bufTests.Next;
  end;
  bufTests.First;
  bufTests.EnableControls;
  Application.ProcessMessages;
end;

procedure TTestesForm.AfterExecuteItem(const TestNumber: Integer;
  const TestResult: TTestResult);
begin
  bufTests.Locate('TestNumber', TestNumber, []);
  bufTests.Edit;
  if TestResult.Pass = tpsPass then
    bufTests.FieldByName('Pass').Value := 'SIM'
  else if TestResult.Pass = tpsFail then
    bufTests.FieldByName('Pass').Value := 'NÃO'
  else
     bufTests.FieldByName('Pass').Value := 'NÃO EXECUTADO';
  bufTests.FieldByName('Message').Value := TestResult.Message;
  bufTests.Post;
end;

class procedure TTestesForm.Open;
begin
  Application.CreateForm(TTestesForm, TestesForm);
  with TestesForm do
  begin
    ConfigureGrid;
    FDBTests := TDBTests.Create(0);
    RegisterTests;

    ShowModal;

    FDBTests.Free;
  end;
end;

end.

