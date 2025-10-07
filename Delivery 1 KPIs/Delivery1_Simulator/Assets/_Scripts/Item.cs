using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Item - Represents an in-game purchasable item
/// =====================================================
/// This class defines the 5 purchasable items that match:
/// - Database items table
/// - Simulator's GetItem() method probabilities (Simulator.cs line 118-131)
/// =====================================================
/// </summary>
[System.Serializable]
public class Item
{
    public int itemId;
    public string itemName;
    public float price;
    public string category;

    /// <summary>
    /// Constructor for creating an item
    /// </summary>
    public Item(int id, string name, float price, string category = "standard")
    {
        this.itemId = id;
        this.itemName = name;
        this.price = price;
        this.category = category;
    }

    /// <summary>
    /// Static catalog of all items
    /// These match the database items table and Simulator probabilities:
    /// - Item 1 (Bronze): 50% chance - $0.99
    /// - Item 2 (Silver): 25% chance - $4.99
    /// - Item 3 (Gold): 15% chance - $9.99
    /// - Item 4 (Platinum): 1% chance - $19.99
    /// - Item 5 (Diamond): 9% chance - $49.99
    /// </summary>
    public static readonly Dictionary<int, Item> Catalog = new Dictionary<int, Item>
    {
        { 1, new Item(1, "Bronze Pack", 0.99f, "starter") },
        { 2, new Item(2, "Silver Pack", 4.99f, "standard") },
        { 3, new Item(3, "Gold Pack", 9.99f, "premium") },
        { 4, new Item(4, "Platinum Pack", 19.99f, "premium") },
        { 5, new Item(5, "Diamond Pack", 49.99f, "exclusive") }
    };

    /// <summary>
    /// Get an item by ID from the catalog
    /// </summary>
    /// <param name="itemId">The item ID (1-5)</param>
    /// <returns>Item object or null if not found</returns>
    public static Item GetItem(int itemId)
    {
        return Catalog.ContainsKey(itemId) ? Catalog[itemId] : null;
    }
}
