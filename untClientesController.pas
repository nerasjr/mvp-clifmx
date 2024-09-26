unit untClientesController;

interface

uses
  System.SysUtils, System.Generics.Collections, Data.DB,
  untCliente, udmPrincipal, FireDAC.Stan.Param, FMX.Dialogs;

type
  TClientesController = class
  private
    FDataModule: TdtmPrincipal;
    function ValidaCliente(ACliente: TCliente): Boolean;
  public
    constructor Create(DataModule: TdtmPrincipal);
    function BuscarCliente(const AIdCliente: Integer): TCliente;
    function GravarCliente(ACliente: TCliente): Boolean;
    function NovoCliente(): TCliente;
    function ExcluirCliente(ACliente: TCliente): Boolean;
  end;

implementation

function TClientesController.BuscarCliente(const AIdCliente: Integer): TCliente;
begin
  Result := nil;
  FDataModule.qryExecute.Close;
  FDataModule.qryExecute.SQL.Text := 'SELECT ' +
                                     '  Cod_Cliente, ' +
                                     '  Nome_Cliente, ' +
                                     '  DataNasc_Cliente ' +
                                     'FROM CadCli ' +
                                     'WHERE Id_Cliente = :idcli;';

  FDataModule.qryExecute.ParamByName('idcli').Value := AIdCliente;
  FDataModule.qryExecute.Open;
  if FDataModule.qryExecute.IsEmpty then
    ShowMessage('Cliente não encontrado!')
  else
  begin
    Result := TCliente.Create;
    Result.Id := AIdCliente;
    Result.Codigo := FDataModule.qryExecute.FieldByName('Cod_Cliente').AsInteger;
    Result.Nome :=  FDataModule.qryExecute.FieldByName('Nome_Cliente').AsString;
    Result.DtNasc := FDataModule.qryExecute.FieldByName('DataNasc_Cliente').AsDateTime;
  end;
end;

constructor TClientesController.Create(DataModule: TdtmPrincipal);
begin
  inherited Create;
  FDataModule := DataModule;
end;

function TClientesController.ExcluirCliente(ACliente: TCliente): Boolean;
begin
  Result := False;
  FDataModule.FDTransaction.StartTransaction;
  try
    if ACliente.Id > 0 then
    begin
      FDataModule.qryExecute.SQL.Text := 'DELETE FROM CadCli ' +
                                         'WHERE Id_Cliente = :idcli;';
      FDataModule.qryExecute.Params.ParamByName('idcli').AsInteger := ACliente.Id;
      FDataModule.qryExecute.ExecSQL;
      FDataModule.FDTransaction.Commit;
      Result := True;
    end;
except
    FDataModule.FDTransaction.Rollback;
  end;

end;

function TClientesController.GravarCliente(ACliente: TCliente): Boolean;
begin
  Result := False;
  if not ValidaCliente(ACliente) then
    Exit;

  FDataModule.FDTransaction.StartTransaction;
  try
    if ACliente.Id > 0 then
    begin
      FDataModule.qryExecute.SQL.Text := 'UPDATE CadCli ' +
                                         '  SET Cod_Cliente = :codigo, ' +
                                         '  Nome_Cliente = :nome, ' +
                                         '  DataNasc_Cliente = :dtnasc ' +
                                         'WHERE Id_Cliente = :idcli;';

      FDataModule.qryExecute.Params.ParamByName('idcli').AsInteger := ACliente.Id;
    end
    else
    begin
      FDataModule.qryExecute.SQL.Text := 'INSERT INTO CadCli (' +
                                         '  Cod_Cliente, ' +
                                         '  Nome_Cliente, ' +
                                         '  DataNasc_Cliente ' +
                                         ') VALUES (' +
                                         '  :codigo,' +
                                         '  :nome,' +
                                         '  :dtnasc);';
    end;
    FDataModule.qryExecute.ParamByName('codigo').Value := ACliente.Codigo;
    FDataModule.qryExecute.ParamByName('nome').Value :=  ACliente.Nome;
    FDataModule.qryExecute.ParamByName('dtnasc').AsDateTime :=  ACliente.DtNasc;
    FDataModule.qryExecute.ExecSQL;
    FDataModule.FDTransaction.Commit;
    Result := True;
  except
    FDataModule.FDTransaction.Rollback;
  end;
end;

function TClientesController.NovoCliente: TCliente;
begin
  Result := TCliente.Create;
  Result.Id := 0;
  Result.Codigo := 0;
  Result.Nome := '';
  Result.DtNasc := Now;
end;

function TClientesController.ValidaCliente(ACliente: TCliente): Boolean;
begin
  Result := False;
  FDataModule.qryExecute.SQL.Text := 'SELECT ' +
                                     '  Id_Cliente ' +
                                     'FROM CadCli ' +
                                     'WHERE Cod_Cliente = :codcli ';
  if ACliente.Id > 0 then
  begin
    FDataModule.qryExecute.SQL.Text := FDataModule.qryExecute.SQL.Text +
                                       ' AND Id_Cliente <> :idcli;';
    FDataModule.qryExecute.ParamByName('idcli').Value := ACliente.Id;
  end;
  FDataModule.qryExecute.ParamByName('codcli').Value := ACliente.Codigo;
  FDataModule.qryExecute.Open;
  if not FDataModule.qryExecute.IsEmpty then
    ShowMessage('Já existe um cliente cadastrado com este código!')
  else if ACliente.Codigo < 1 then
    ShowMessage('Informe um código válido!')
  else if ACliente.Nome = '' then
    ShowMessage('Informe um nome para o cliente!')
  else
    Result := True;
end;

end.

