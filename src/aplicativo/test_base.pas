unit test_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls,
  LCLIntf, Generics.Collections;

type

  TTestPassStatus = (tpsNotExecuted, tpsFail, tpsPass);

  TTestResult = record
    Pass: TTestPassStatus;
    Message: string;
  end;

  TTestMethodDelegate = function: TTestResult of object;

  { TTestItem }

  TTestItem = class
  private
    FTestMethod: TTestMethodDelegate;
    FTestResult: TTestResult;
    FTitle: string;
    TTestResult: TTestResult;
  public
    property TestMethod: TTestMethodDelegate read FTestMethod write FTestMethod;
    property Title: string read FTitle write FTitle;
    property TestResult: TTestResult read FTestResult write TTestResult;
  end;

  { TTestsBase }

  TTestsBase = class
  protected
    FTestItemList: specialize TList<TTestItem>;
    procedure AddTestItem(ATestMethod: TTestMethodDelegate; ATitle: string);

    procedure IsGreaterThan(Value, Reference: Integer; var TestResult: TTestResult);
    procedure IsEquals(Value1, Value2: string; var TestResult: TTestResult);
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterTests; virtual; abstract;
    procedure Execute;
  end;

implementation

{ TTestsBase }

procedure TTestsBase.AddTestItem(ATestMethod: TTestMethodDelegate; ATitle: string);
var
  item: TTestItem;
begin
  item := TTestItem.Create;
  item.TestMethod := ATestMethod;
  item.Title := ATitle;
  FTestItemList.Add(item);
end;

procedure TTestsBase.IsGreaterThan(Value, Reference: Integer;
  var TestResult: TTestResult);
begin
  if Value > Reference then
    TestResult.Pass := tpsPass
  else
    TestResult.Pass := tpsFail
end;

procedure TTestsBase.IsEquals(Value1, Value2: string;
  var TestResult: TTestResult);
begin
  if Value1 = Value2 then
    TestResult.Pass := tpsPass
  else
    TestResult.Pass := tpsFail
end;

constructor TTestsBase.Create;
begin
  FTestItemList := specialize TList<TTestItem>.Create;
end;

destructor TTestsBase.Destroy;
var
  item: TTestItem;
begin
  for item in FTestItemList do
  begin
    item.Free;
  end;

  inherited;
end;

procedure TTestsBase.Execute;
var
  item: TTestItem;
  testResult: TTestResult;
begin
  for item in FTestItemList do
  begin
    try
      testResult := item.TestMethod();
    except
      on ex: Exception do
      begin
        testResult.Pass := tpsPass;
        testResult.Message := ex.Message;
      end;
    end;
    item.TestResult := testResult;
  end;
end;



end.

