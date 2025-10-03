using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Represents an in-game purchasable item with pricing information
/// </summary>
[System.Serializable]
public class Item
{
    public int itemId;
    public string itemName;
    public float price;
    public string category;

    public Item(int id, string name, float price, string category = "standard")
    {
        this.itemId = id;
        this.itemName = name;
        this.price = price;
        this.category = category;
    }

    // Static catalog matching database items
    public static readonly Dictionary<int, Item> Catalog = new Dictionary<int, Item>
    {
        { 1, new Item(1, "Bronze Pack", 0.99f, "starter") },
        { 2, new Item(2, "Silver Pack", 4.99f, "standard") },
        { 3, new Item(3, "Gold Pack", 9.99f, "premium") },
        { 4, new Item(4, "Platinum Pack", 19.99f, "premium") },
        { 5, new Item(5, "Diamond Pack", 49.99f, "exclusive") }
    };

    public static Item GetItem(int itemId)
    {
        return Catalog.ContainsKey(itemId) ? Catalog[itemId] : null;
    }
}
