-- ╔══════════════════════════════════════════╗
-- ║  webhook.lua  — Yi Da Mu Sake  v8.2      ║
-- ║  Modul: dipanggil oleh main.lua          ║
-- ╚══════════════════════════════════════════╝

return function(refs, T, gui)

    -- ── Layanan & konfigurasi ────────────────────────────────
    local Players     = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer

    local WEBHOOK_URL = "https://discord.com/api/webhooks/1494516679126945922/N5iZRx8y5yi5SuzOQ_iDTWyVizEFsZFmwONQ3QLb_po5xCFpw-yDkqHWIntrQrJ_PoqX"
    local INTERVAL    = 600  -- detik (10 menit)

    -- ── Deteksi executor HTTP ────────────────────────────────
    local httpRequest = (syn  and syn.request)
        or (http and http.request)
        or (typeof(request) == "function" and request)
        or nil

    if not httpRequest then
        warn("[Webhook] Executor tidak mendukung HTTP request — modul tidak aktif.")
        if refs.setWhStat then refs.setWhStat("Executor tidak didukung", T.red) end
        return
    end

    -- ── State internal ───────────────────────────────────────
    local savedInventory = {}   -- snapshot terakhir
    local reportCount    = 0
    local disconnected   = false

    -- ── Helper: kirim embed ke Discord ──────────────────────
    local function sendEmbed(payload)
        local body = HttpService:JSONEncode({
            username   = "Yi Da Mu Sake",
            avatar_url = "https://i.imgur.com/AfFp7pu.png",
            embeds     = { payload },
        })
        local ok, err = pcall(function()
            httpRequest({
                Url     = WEBHOOK_URL,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = body,
            })
        end)
        if ok  then print("[Webhook] ✅ Terkirim")
        else        warn("[Webhook] ❌ Gagal: " .. tostring(err)) end
        return ok
    end

    -- ── Helper: ambil storage ────────────────────────────────
    local function getStorage()
        local ok, s = pcall(function()
            return LocalPlayer.PlayerGui
                .InventoryPanelUI.MainFrame.Frame.Content
                .Holder.StorageHolder.Storage
        end)
        return (ok and s) or nil
    end

    -- ── Baca inventory, filter hanya item yang dipilih ───────
    -- Jika tidak ada item dipilih → catat semua
    local function getFilteredInventory()
        local result  = {}
        local storage = getStorage()
        if not storage then return result end

        local selected    = refs.getSelectedWhItems and refs.getSelectedWhItems() or {}
        local selectedSet = {}
        for _, name in ipairs(selected) do selectedSet[name] = true end
        local hasFilter   = (#selected > 0)

        for _, slot in ipairs(storage:GetChildren()) do
            -- Format child: "Item_[NamaItem]"
            local slotKey = slot.Name:match("^Item_(.+)$")
            if slotKey and (not hasFilter or selectedSet[slotKey]) then
                local slotFrame = slot:FindFirstChild("Slot")
                if slotFrame then
                    local holder = slotFrame:FindFirstChild("Holder")
                    if holder then
                        local nameLbl = holder:FindFirstChild("ItemName")
                        local qtyLbl  = holder:FindFirstChild("Quantity")
                        local display = (nameLbl and nameLbl.Text ~= "") and nameLbl.Text or slotKey
                        local raw     = (qtyLbl  and qtyLbl.Text  ~= "") and qtyLbl.Text  or "0"
                        local qty     = tonumber(raw:match("%d+")) or 0
                        result[display] = (result[display] or 0) + qty
                    end
                end
            end
        end
        return result
    end

    -- ── Baca player data ─────────────────────────────────────
    local function getPlayerData()
        local folder = LocalPlayer:FindFirstChild("Data")
        if not folder then return {} end
        local out = {}
        for _, child in ipairs(folder:GetDescendants()) do
            if child:IsA("ValueBase") then out[child.Name] = tostring(child.Value) end
        end
        return out
    end

    -- ── Format field Discord ─────────────────────────────────
    local function fmtDataField(data)
        local lines = {}
        for k, v in pairs(data) do
            table.insert(lines, string.format("`%s` → **%s**", k, v))
        end
        local s = #lines > 0 and table.concat(lines, "\n") or "*Tidak ada data*"
        return #s > 1024 and s:sub(1, 1020).."..." or s
    end

    local function fmtInventoryField(current, prev)
        local lines = {}
        for name, qty in pairs(current) do
            if prev[name] == nil then
                table.insert(lines, string.format("• **%s** — %d 🆕", name, qty))
            elseif qty > prev[name] then
                table.insert(lines, string.format("• **%s** — %d (+%d)", name, qty, qty - prev[name]))
            elseif qty < prev[name] then
                table.insert(lines, string.format("• **%s** — %d (%d)", name, qty, qty - prev[name]))
            else
                table.insert(lines, string.format("• **%s** — %d", name, qty))
            end
        end
        if #lines == 0 then return "*Tidak ada perubahan pada item terpilih*" end
        local s = table.concat(lines, "\n")
        return #s > 1024 and s:sub(1, 1020).."..." or s
    end

    -- ── Laporan awal ─────────────────────────────────────────
    local function sendInitialReport()
        local selected = refs.getSelectedWhItems and refs.getSelectedWhItems() or {}
        local selStr   = #selected > 0 and table.concat(selected, ", ") or "*Semua item*"
        if #selStr > 300 then selStr = selStr:sub(1, 297).."..." end

        local current = getFilteredInventory()
        sendEmbed({
            title  = "🟢 Webhook Aktif — " .. LocalPlayer.Name,
            color  = 0x57F287,
            fields = {
                { name = "👤 Player",
                  value = string.format("`%s`  (ID: `%d`)", LocalPlayer.Name, LocalPlayer.UserId),
                  inline = false },
                { name = "🔍 Item Dipantau",
                  value = selStr,
                  inline = false },
                { name = "🎒 Snapshot Awal",
                  value = fmtInventoryField(current, {}),
                  inline = false },
            },
            footer    = { text = "Sailor Piece • Yi Da Mu Sake v8.2" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        })
        savedInventory = current
    end

    -- ── Laporan berkala ──────────────────────────────────────
    local function sendPeriodicReport()
        reportCount = reportCount + 1
        local current = getFilteredInventory()
        local ok = sendEmbed({
            title  = string.format("📊 Laporan #%d — %s", reportCount, LocalPlayer.Name),
            color  = 0x5865F2,
            fields = {
                { name  = "🗂️ Player Data",
                  value = fmtDataField(getPlayerData()),
                  inline = false },
                { name  = "🎒 Perubahan Inventory",
                  value = fmtInventoryField(current, savedInventory),
                  inline = false },
            },
            footer    = { text = "Sailor Piece • Yi Da Mu Sake v8.2" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        })
        if ok then savedInventory = current end
        if refs.setWhStat then
            refs.setWhStat("Laporan #"..reportCount.." dikirim", T.green)
        end
    end

    -- ── Laporan disconnect ───────────────────────────────────
    local function sendDisconnect()
        sendEmbed({
            title       = "🔴 Disconnected — " .. LocalPlayer.Name,
            description = string.format(
                "**%s** telah terputus dari server.\nWaktu: `%s`",
                LocalPlayer.Name, os.date("!%Y-%m-%d %H:%M:%S UTC")
            ),
            color     = 0xED4245,
            footer    = { text = "Sailor Piece • Yi Da Mu Sake v8.2" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        })
    end

    -- ── Deteksi disconnect ───────────────────────────────────
    Players.PlayerRemoving:Connect(function(p)
        if p == LocalPlayer and not disconnected then
            disconnected = true; sendDisconnect()
        end
    end)
    LocalPlayer.CharacterRemoving:Connect(function()
        task.delay(5, function()
            if not LocalPlayer.Character and not disconnected then
                disconnected = true; sendDisconnect()
            end
        end)
    end)

    -- ── Loop utama ───────────────────────────────────────────
    task.spawn(function()
        task.wait(2)  -- tunggu UI siap

        while true do
            if refs.getWhOn and refs.getWhOn() then
                -- Reset state tiap sesi baru
                savedInventory = {}; reportCount = 0

                if refs.setWhStat then refs.setWhStat("Inisialisasi...", T.amber) end
                sendInitialReport()
                if refs.setWhStat then refs.setWhStat("Aktif — laporan tiap 10m", T.green) end

                while refs.getWhOn and refs.getWhOn() do
                    -- Countdown
                    for i = 1, INTERVAL do
                        if not (refs.getWhOn and refs.getWhOn()) then break end
                        task.wait(1)
                        if refs.setWhStat and i % 60 == 0 then
                            local rem = INTERVAL - i
                            refs.setWhStat(
                                string.format("Laporan dalam %dm %ds", math.floor(rem/60), rem%60),
                                T.textSub
                            )
                        end
                    end
                    if refs.getWhOn and refs.getWhOn() then
                        if refs.setWhStat then refs.setWhStat("Mengirim laporan...", T.amber) end
                        sendPeriodicReport()
                    end
                end

                -- Webhook dimatikan
                savedInventory = {}; reportCount = 0
                if refs.setWhStat then refs.setWhStat("Nonaktif", T.textDim) end
            end
            task.wait(1)
        end
    end)

    print("[Webhook] ✅ Modul aktif")
end
