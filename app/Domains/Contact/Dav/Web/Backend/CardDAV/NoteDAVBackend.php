<?php

namespace App\Domains\Contact\Dav\Web\Backend\CardDAV;

use App\Models\Vault;
use Illuminate\Support\Collection;
use Sabre\CardDAV\Backend\AbstractBackend;

/**
 * Backend for exposing per-vault notes over a DAV collection.
 *
 * Note: this class intentionally does NOT implement IDAVBackend, even though it
 * provides the same conceptual operations (id, uri, lookup, listing, extension)
 * as the existing CardDAV/CalDAV backends.
 */
class NoteDAVBackend extends AbstractBackend
{
    private ?Vault $vault = null;

    public function withVault(Vault $vault): self
    {
        $this->vault = $vault;

        return $this;
    }

    public function backendId(?string $collectionId = null): string
    {
        return 'notes-'.($this->vault?->id ?? 'global');
    }

    public function backendUri(): string
    {
        return 'notes.vcf';
    }

    public function getObjectUuid(?string $collectionId, string $uuid)
    {
        return $this->getObjects($collectionId)->firstWhere('uuid', $uuid);
    }

    public function getObjects(?string $collectionId): Collection
    {
        if ($this->vault === null) {
            return collect();
        }

        return collect();
    }

    public function getExtension(): string
    {
        return '.vcf';
    }

    public function getAddressBooksForUser($principalUri)
    {
        return [];
    }

    public function updateAddressBook($addressBookId, \Sabre\DAV\PropPatch $propPatch)
    {
    }

    public function createAddressBook($principalUri, $url, array $properties)
    {
    }

    public function deleteAddressBook($addressBookId)
    {
    }

    public function getCards($addressBookId)
    {
        return [];
    }

    public function getCard($addressBookId, $cardUri)
    {
        return false;
    }

    public function createCard($addressBookId, $cardUri, $cardData)
    {
        return null;
    }

    public function updateCard($addressBookId, $cardUri, $cardData)
    {
        return null;
    }

    public function deleteCard($addressBookId, $cardUri)
    {
        return false;
    }
}
