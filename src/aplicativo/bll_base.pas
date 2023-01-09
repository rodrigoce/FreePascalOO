unit bll_base;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, db_context;

type

  { TBLLBase }

  TBllBase = class
  private
    FDbContext: TDbContext;
  public
    constructor Create(ADbContext: TDbContext); virtual;
    property DbContext: TDbContext read FDbContext;
  end;

implementation

{ TBLLBase }

constructor TBLLBase.Create(ADbContext: TDbContext);
begin
  FDbContext := ADbContext;
end;

end.

