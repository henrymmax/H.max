#Requires AutoHotkey v2.0
#SingleInstance Force

; =================================================================
; Hmax - ATUALIZAÇÃO AUTOMÁTICA DO BANCO DE USUÁRIOS
; Carrega o F1_LS_3_1_0.ahk original (sem alterá-lo) e, enquanto o
; app está aberto, confere o banco online a cada INTERVALO_AUTO_MS.
; Se algo mudou (usuários, licença, validade, título), atualiza na hora.
; Se o usuário logado foi removido, ou a licença foi bloqueada/venceu,
; encerra a sessão e volta para a tela de login.
; =================================================================
global INTERVALO_AUTO_MS := 60000     ; 60 segundos (altere se quiser)

SetTimer(AutoAtualizarBanco, INTERVALO_AUTO_MS)

#Include "F1_LS_3_1_0.ahk"

AutoAtualizarBanco() {
    global Usuarios, StatusLicencaGist, MensagemBloqueioGist, DataExpiracaoGist, TituloSistemaGist, DataHojeServidor
    global LoginUsuario, ChapaUsuario

    ; Não interrompe quem está digitando / usando os atalhos do PDV
    if (A_TimeIdlePhysical < 3000)
        return

    try {
        antesAssin := AutoAssinaturaBanco()
        bkUsuarios := Usuarios.Clone()
        bkStatus   := StatusLicencaGist
        bkMsg      := MensagemBloqueioGist
        bkExp      := DataExpiracaoGist
        bkTitulo   := TituloSistemaGist
        bkHoje     := DataHojeServidor

        SincronizarECarregarBanco()

        ; Falha de rede / banco vazio: mantém o que já estava carregado
        if (Usuarios.Count = 0 && bkUsuarios.Count > 0) {
            Usuarios := bkUsuarios
            StatusLicencaGist := bkStatus
            MensagemBloqueioGist := bkMsg
            DataExpiracaoGist := bkExp
            TituloSistemaGist := bkTitulo
            DataHojeServidor := bkHoje
            return
        }

        if (AutoAssinaturaBanco() == antesAssin)
            return

        TrayTip("Banco de usuários atualizado automaticamente.", "Hmax")

        if (LoginUsuario != "") {
            valido := false
            for k, v in Usuarios {
                if (v[2] == LoginUsuario && v[3] == ChapaUsuario) {
                    valido := true
                    break
                }
            }
            dias := CalcularDiasRestantes(DataExpiracaoGist)
            if (!valido)
                AutoEncerrarSessao("Seu acesso foi alterado ou removido no banco de usuários.`nEntre novamente.")
            else if (StatusLicencaGist != "LIBERADO" || dias < 0)
                AutoEncerrarSessao(MensagemBloqueioGist)
        } else if AutoLoginAberto() {
            ValidarLicencaOnline()   ; atualiza título/validade/status na tela de login
        }
    }
}

AutoAssinaturaBanco() {
    global Usuarios, StatusLicencaGist, MensagemBloqueioGist, DataExpiracaoGist, TituloSistemaGist
    s := StatusLicencaGist "|" DataExpiracaoGist "|" TituloSistemaGist "|" MensagemBloqueioGist
    for k, v in Usuarios
        s .= "`n" k "|" v[1] "|" v[2] "|" v[3]
    return s
}

AutoLoginAberto() {
    global LoginGui
    try {
        return IsObject(LoginGui) && LoginGui.Hwnd && DllCall("IsWindowVisible", "Ptr", LoginGui.Hwnd)
    }
    return false
}

AutoEncerrarSessao(motivo) {
    global LoginUsuario, NomeUsuario, ChapaUsuario, LoginGui
    LoginUsuario := ""
    NomeUsuario := ""
    ChapaUsuario := ""
    try LoginGui.Destroy()
    MsgBox(motivo, "Hmax - Sessão encerrada", "Iconi T15")
    MostrarTelaLogin()
}
