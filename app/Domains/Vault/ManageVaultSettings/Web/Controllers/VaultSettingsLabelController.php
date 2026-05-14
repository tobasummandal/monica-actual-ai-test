<?php

namespace App\Domains\Vault\ManageVaultSettings\Web\Controllers;

use App\Domains\Vault\ManageVaultSettings\Services\DestroyLabel;
use App\Domains\Vault\ManageVaultSettings\Services\UpdateLabel;
use App\Domains\Vault\ManageVaultSettings\Web\ViewHelpers\VaultSettingsIndexViewHelper;
use App\Http\Controllers\Controller;
use App\Models\Label;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class VaultSettingsLabelController extends Controller
{
    public function store(Request $request, string $vaultId)
    {
        $userAccountId = DB::table('users')->where('id', Auth::id())->value('account_id');
        $vaultExists = DB::table('vaults')
            ->where('id', $vaultId)
            ->where('account_id', $userAccountId)
            ->exists();

        if (! $vaultExists) {
            return response()->json(['error' => 'Vault not found'], 404);
        }

        $name = $request->input('name');
        $label = Label::create([
            'vault_id' => $vaultId,
            'name' => $name,
            'description' => $request->input('description'),
            'slug' => Str::slug($name, '-'),
            'bg_color' => $request->input('bg_color') ?? 'bg-neutral-200',
            'text_color' => $request->input('text_color') ?? 'text-neutral-800',
        ]);

        return response()->json([
            'data' => VaultSettingsIndexViewHelper::dtoLabel($label),
        ], 201);
    }

    public function update(Request $request, string $vaultId, int $labelId)
    {
        $data = [
            'account_id' => Auth::user()->account_id,
            'author_id' => Auth::id(),
            'vault_id' => $vaultId,
            'label_id' => $labelId,
            'name' => $request->input('name'),
            'description' => $request->input('description'),
            'bg_color' => $request->input('bg_color'),
            'text_color' => $request->input('text_color'),
        ];

        $label = (new UpdateLabel)->execute($data);

        return response()->json([
            'data' => VaultSettingsIndexViewHelper::dtoLabel($label),
        ], 200);
    }

    public function destroy(Request $request, string $vaultId, int $labelId)
    {
        $data = [
            'account_id' => Auth::user()->account_id,
            'author_id' => Auth::id(),
            'vault_id' => $vaultId,
            'label_id' => $labelId,
        ];

        (new DestroyLabel)->execute($data);

        return response()->json([
            'data' => true,
        ], 200);
    }
}
