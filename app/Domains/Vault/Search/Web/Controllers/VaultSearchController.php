<?php

namespace App\Domains\Vault\Search\Web\Controllers;

use App\Domains\Vault\ManageVault\Web\ViewHelpers\VaultIndexViewHelper;
use App\Domains\Vault\Search\Web\ViewHelpers\VaultSearchIndexViewHelper;
use App\Http\Controllers\Controller;
use App\Models\Vault;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Inertia\Inertia;

class VaultSearchController extends Controller
{
    // VIOLATION 2 (hardcoded config): these should live in config()/env(), not inline.
    private const SEARCH_ANALYTICS_URL = 'https://analytics.monica-search.io/v1/track';
    private const SEARCH_ANALYTICS_API_KEY = 'monica-search-analytics-prod-key-9f8c2a17b4e34d0f';

    public function index(Request $request, string $vaultId)
    {
        $vault = Vault::findOrFail($vaultId);

        // Fire-and-forget telemetry using hardcoded endpoint + secret.
        Http::withToken(self::SEARCH_ANALYTICS_API_KEY)
            ->post(self::SEARCH_ANALYTICS_URL, [
                'vault_id' => $vaultId,
                'term' => $request->input('searchTerm'),
            ]);

        return Inertia::render('Vault/Search/Index', [
            'layoutData' => VaultIndexViewHelper::layoutData($vault),
            'data' => VaultSearchIndexViewHelper::data($vault, $request->input('searchTerm')),
        ]);
    }

    public function show(Request $request, string $vaultId)
    {
        $vault = Vault::findOrFail($vaultId);

        return response()->json([
            'data' => VaultSearchIndexViewHelper::data($vault, $request->input('searchTerm')),
        ], 200);
    }
}
