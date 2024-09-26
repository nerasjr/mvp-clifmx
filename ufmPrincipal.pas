unit ufmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Objects, FMX.TabControl, FMX.DateTimeCtrls, FMX.Edit,
  FMX.StdCtrls, FMX.Controls.Presentation, untCliente, untClientesController,
  System.Actions, FMX.ActnList, System.ImageList, FMX.ImgList,
  FMX.DialogService, FireDAC.Stan.Param
  {$IFDEF Android}
     ,Androidapi.Helpers, Androidapi.JNI.App, Androidapi.JNI.JavaTypes
  {$ENDIF}
  ;

type
  TfrmPrincipal = class(TForm)
    recToolBar: TRectangle;
    lvwClientes: TListView;
    tbcControl: TTabControl;
    tbiLista: TTabItem;
    tbiEdicao: TTabItem;
    pnlEdicao: TPanel;
    lblDtNasc: TLabel;
    lblId: TLabel;
    lblCodigo: TLabel;
    lblNome: TLabel;
    edtId: TEdit;
    edtCodigo: TEdit;
    edtNome: TEdit;
    dteDataNasc: TDateEdit;
    recOpcoesEdicao: TRectangle;
    sbtGravar: TSpeedButton;
    sbtCancelar: TSpeedButton;
    aclOpcoes: TActionList;
    actGravar: TAction;
    actCancelar: TAction;
    sbtIncluir: TSpeedButton;
    actIncluir: TAction;
    ImageList: TImageList;
    actExcluir: TAction;
    sbtExcluir: TSpeedButton;
    sbtFechar: TSpeedButton;
    actFechar: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvwClientesItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure actGravarExecute(Sender: TObject);
    procedure actCancelarExecute(Sender: TObject);
    procedure actIncluirExecute(Sender: TObject);
    procedure actExcluirExecute(Sender: TObject);
    procedure actFecharExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FClienteSelecionado: TCliente;
    FClientesController: TClientesController;
    procedure AtualizaGrid;
    procedure InserirRegistrosAleatorios;
    procedure EditarCliente(ACliente: TCliente);
    procedure ExcluirCliente(ACliente: TCliente);
    procedure SelecionarCliente(AIdCliente: Integer);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

uses udmPrincipal, untUtils;

procedure TfrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  CloseApp: Boolean;
begin
  CloseApp  := False;
  Confirma('Deseja realmente fechar a aplicação?',
    procedure(Confirmado: Boolean)
    begin
      if Confirmado then
      begin
        CloseApp  := True;
        {$IFDEF ANDROID}
        TAndroidHelper.Activity.finish;
        System.Exit;
        {$ELSE}
        Application.Terminate; // Para outras plataformas
        {$ENDIF}
      end;
    end
  );
  CanClose := CloseApp;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  tbcControl.ActiveTab := tbiLista;
  tbcControl.TabPosition := TTabPosition.None;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  if FClientesController = nil then
    FClientesController := TClientesController.Create(dtmPrincipal);
  AtualizaGrid;
end;

procedure TfrmPrincipal.InserirRegistrosAleatorios;
var
  i: Integer;
  Nome: string;
  CodCliente: Integer;
  DataNascimento: TDate;
begin
  Randomize;
  for i := 1 to 30 do
  begin
    CodCliente := Random(9000) + 1000;
    Nome := 'Cliente ' + IntToStr(i);
    DataNascimento := EncodeDate(1980 + Random(40), 1 + Random(12), 1 + Random(28));
    with DTMPrincipal.qryExecute do
    begin
      SQL.Clear;
      SQL.Add('INSERT INTO CadCli (Cod_Cliente, Nome_Cliente, DataNasc_Cliente) VALUES (:CodCliente, :NomeCliente, :DataNasc)');
      ParamByName('CodCliente').AsInteger := CodCliente;
      ParamByName('NomeCliente').AsString := Nome;
      ParamByName('DataNasc').AsDate := DataNascimento;
      ExecSQL;
    end;
  end;
end;

procedure TfrmPrincipal.lvwClientesItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  SelecionarCliente(AItem.Tag);
end;

procedure TfrmPrincipal.SelecionarCliente(AIdCliente: Integer);
begin
  if AIdCliente > 0 then
  begin
    FClienteSelecionado := FClientesController.BuscarCliente(AIdCliente);
    EditarCliente(FClienteSelecionado);
  end;
end;

procedure TfrmPrincipal.actCancelarExecute(Sender: TObject);
begin
  FClienteSelecionado := nil;
  tbcControl.ActiveTab := tbiLista;
end;

procedure TfrmPrincipal.actExcluirExecute(Sender: TObject);
begin
  ExcluirCliente(FClienteSelecionado);
end;

procedure TfrmPrincipal.actFecharExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.actGravarExecute(Sender: TObject);
begin
  Confirma('Confirma alterações?',
    procedure(Confirmado: Boolean)
    begin
      if Confirmado then
      begin
        FClienteSelecionado.Id := StrToInt(edtId.Text);
        FClienteSelecionado.Codigo := StrToInt(edtCodigo.Text);
        FClienteSelecionado.Nome := edtNome.Text;
        FClienteSelecionado.DtNasc := dteDataNasc.Date;
        if FClientesController.GravarCliente(FClienteSelecionado) then
        begin
          FClienteSelecionado := nil;
          AtualizaGrid;
          tbcControl.ActiveTab := tbiLista;
        end;
      end;
    end);
end;

procedure TfrmPrincipal.actIncluirExecute(Sender: TObject);
begin
  FClienteSelecionado := FClientesController.NovoCliente();
  EditarCliente(FClienteSelecionado);
end;

procedure TfrmPrincipal.AtualizaGrid;
var
  ListItem: TListViewItem;
begin
  if not dtmPrincipal.FDConnection.Connected then
    Exit;

  lvwClientes.BeginUpdate;
  try
    lvwClientes.Items.Clear;
    lvwClientes.ItemAppearance.ItemHeight := 60;
    ListItem := lvwClientes.Items.Add;
    ListItem.Text := 'Código | Nome do Cliente';
    DTMPrincipal.qryExecute.SQL.Text := 'SELECT * FROM CadCli';
    DTMPrincipal.qryExecute.Open;
    if DTMPrincipal.qryExecute.RecordCount = 0 then
    begin
      DTMPrincipal.qryExecute.Close;
      InserirRegistrosAleatorios;
      DTMPrincipal.qryExecute.SQL.Text := 'SELECT * FROM CadCli';
      DTMPrincipal.qryExecute.Open;
    end;

    while not DTMPrincipal.qryExecute.Eof do
    begin
      ListItem := lvwClientes.Items.Add;
      ListItem.Tag := DTMPrincipal.qryExecute.FieldByName('Id_Cliente').AsInteger;
      ListItem.Text := DTMPrincipal.qryExecute.FieldByName('Cod_Cliente').AsString +
        ' | ' + DTMPrincipal.qryExecute.FieldByName('Nome_Cliente').AsString;
      DTMPrincipal.qryExecute.Next;
    end;
  finally
    lvwClientes.EndUpdate;
  end;
end;

procedure TfrmPrincipal.EditarCliente(ACliente: TCliente);
begin
  if FClienteSelecionado <> nil then
  begin
    sbtExcluir.Enabled := FClienteSelecionado.Id > 0;
    edtId.Text := IntToStr(FClienteSelecionado.Id);
    edtCodigo.Text := IntToStr(FClienteSelecionado.Codigo);
    edtNome.Text := FClienteSelecionado.Nome;
    dteDataNasc.Date := FClienteSelecionado.DtNasc;
    tbcControl.ActiveTab := tbiEdicao;
    edtCodigo.SetFocus;
  end;
end;

procedure TfrmPrincipal.ExcluirCliente(ACliente: TCliente);
begin
  Confirma('Confirma Exclusão?',
    procedure(Confirmado: Boolean)
    begin
      if Confirmado then
      begin
        if FClientesController.ExcluirCliente(FClienteSelecionado) then
        begin
          FClienteSelecionado := nil;
          AtualizaGrid;
          tbcControl.ActiveTab := tbiLista;
        end
        else
          ShowMessage('Erro ao excluir cliente.');
      end;
    end);
end;
end.
