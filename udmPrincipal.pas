unit udmPrincipal;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, System.IOUtils;

type
  TdtmPrincipal = class(TDataModule)
    qryExecute: TFDQuery;
    FDTransaction: TFDTransaction;
    FDConnection: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dtmPrincipal: TdtmPrincipal;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TdtmPrincipal.DataModuleCreate(Sender: TObject);
var
  dbFileName: String;
begin
  {$IFDEF ANDROID}
  dbFileName := TPath.Combine(TPath.GetDocumentsPath, 'BancoCliente.db');
  {$ELSE}
  dbFileName := '..\..\db';
  ForceDirectories(dbFileName);
  dbFileName := dbFileName + '\BancoCliente.db';
  {$ENDIF}
  FDConnection.Params.Clear;
  FDConnection.Params.Add('DriverID=SQLite');
  FDConnection.Params.Add('Database=' + dbFileName);
  FDConnection.Connected := True;
  qryExecute.SQL.Text := 'CREATE TABLE IF NOT EXISTS CadCli ' +
                         '(Id_Cliente INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                         'Cod_Cliente INTEGER TYPE UNIQUE, ' +
                         'Nome_Cliente VARCHAR(40), ' +
                         'DataNasc_Cliente DATE)';
  qryExecute.ExecSQL;
end;

end.
