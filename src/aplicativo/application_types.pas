unit application_types;

{$mode ObjFPC}{$H+}

interface

uses
  Classes;

type
  TOperationResult = record
    Success: Boolean;
    Message: string;
  end;

  TValidationMsgItem = class
  private
    FClassFieldName: string;
    FMsgList: TStringList;
  public
    property ClassPropName: string read FClassFieldName write FClassFieldName;
    property MsgList: TStringList read FMsgList write FMsgList;
  end;

  { TRollbackOjb }

  TRollbackOjb = class
  private
    FCopyOfOldProp: TObject;
    FInstanceEntityBase: TObject;
  public
    destructor Destroy; override;
    property InstanceEntityBase: TObject read FInstanceEntityBase write FInstanceEntityBase;
    property CopyOfOldVersion: TObject read FCopyOfOldProp write FCopyOfOldProp;
  end;

implementation

{ TRollbackOjb }

destructor TRollbackOjb.Destroy;
begin
  CopyOfOldVersion.Free;
  inherited;
end;

end.

