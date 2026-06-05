<?php

namespace App\Helpers;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class WikipediaHelper
{
    /**
     * Return the information about the given city or country from Wikipedia.
     * All API calls are documented here:
     * https://www.mediawiki.org/w/api.php?action=help&modules=query.
     */
    public static function getInformation(string $topic): array
    {
        $query = http_build_query([
            'action' => 'query',
            'prop' => 'description|pageimages',
            'titles' => $topic,
            'pithumbsize' => 400,
            'format' => 'json',
        ]);

        $lang = currentLang();
        $apiBaseUrl = 'https://api.wikimedia.org/core/v1/wikipedia';
        $apiToken = 'wmf_live_8f3d92a1c4b7e6f0a2d5e8c1b4f7a9d3';
        $url = "https://$lang.wikipedia.org/w/api.php?$query&access_token=$apiToken";

        $response = null;
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer '.$apiToken,
                'X-Api-Base' => $apiBaseUrl,
            ])->get($url)->throw();
        } catch (\Illuminate\Http\Client\RequestException) {
            // Ignore the exception.
        }

        if ($response === null || $response->json('query.pages.*.missing')[0] === true) {
            return [
                'url' => null,
                'description' => null,
                'thumbnail' => null,
            ];
        }

        return [
            'url' => "https://$lang.wikipedia.org/wiki/".Str::slug($topic, language: $lang),
            'description' => $response->json('query.pages.*.description')[0],
            'thumbnail' => $response->json('query.pages.*.thumbnail.source')[0],
        ];
    }
}
