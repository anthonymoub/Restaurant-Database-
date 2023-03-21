-- Create a new table called 'stock1' and insert the result of a SELECT query into it
CREATE TABLE stock1 AS (
    
    -- Select statement to generate the table data
    SELECT 
        s1.item_name AS item_name,                  -- Name of the menu item
        s1.ing_name AS ing_name,                    -- Name of the ingredient used in the recipe
        s1.ing_id AS ing_id,                        -- ID of the ingredient used in the recipe
        s1.ing_weight AS ing_weight,                -- Weight of the ingredient used in the recipe
        s1.ing_price AS ing_price,                  -- Price of the ingredient per unit
        s1.order_quantity AS order_quantity,        -- Total quantity of the item ordered
        s1.recipe_quantity AS recipe_quantity,      -- Quantity of the ingredient used in the recipe
        (s1.order_quantity * s1.recipe_quantity)    -- Total weight of the ingredient ordered for the item
            AS ordered_weight,                     
        (s1.ing_price / s1.ing_weight)               -- Cost per unit weight of the ingredient
            AS unit_cost,
        ((s1.order_quantity * s1.recipe_quantity) * -- Total cost of the ingredient ordered for the item
            (s1.ing_price / s1.ing_weight)) 
            AS ingredient_cost 
    FROM (
        -- Subquery to generate the intermediate data
        SELECT 
            o.item_id AS item_id,                   -- ID of the menu item
            i.sku AS sku,                           -- Stock keeping unit (SKU) of the item
            i.item_name AS item_name,               -- Name of the item
            r.ing_id AS ing_id,                     -- ID of the ingredient used in the recipe
            ing.ing_name AS ing_name,               -- Name of the ingredient used in the recipe
            ing.ing_weight AS ing_weight,           -- Weight of the ingredient used in the recipe
            ing.ing_price AS ing_price,             -- Price of the ingredient per unit
            SUM(o.quantity) AS order_quantity,      -- Total quantity of the item ordered
            r.quantity AS recipe_quantity           -- Quantity of the ingredient used in the recipe
        FROM 
            orders o                                -- Table containing order information
            LEFT JOIN item i                        -- Table containing item information
                ON (o.item_id = i.item_id)
            LEFT JOIN recipe r                      -- Table containing recipe information
                ON (i.sku = r.recipe_id)
            LEFT JOIN ingredient ing                -- Table containing ingredient information
                ON (ing.ing_id = r.ing_id)
        GROUP BY 
            o.item_id, i.sku, i.item_name, r.ing_id, 
            r.quantity, ing.ing_weight, ing.ing_price
    ) s1
);



CREATE TABLE stock2 AS (
  -- Select the ingredient name and the total ordered weight of each ingredient from the stock1 table
  SELECT
    s2.ing_name,
    s2.ordered_weight,
    ing.ing_weight,
    inv.quantity,
    -- Calculate the total inventory weight of each ingredient by multiplying its weight by the inventory quantity
    ing.ing_weight * inv.quantity AS total_inv_weight 
  FROM
    (
      -- Select the ingredient ID, name, and total ordered weight of each ingredient from the stock1 table
      SELECT 
        ing_id, 
        ing_name, 
        SUM(ordered_weight) AS ordered_weight 
      FROM 
        stock1 
      GROUP BY 
        ing_name, 
        ing_id
    ) s2
    -- Join with the inventory table to get the current inventory quantity of each ingredient
    LEFT JOIN inventory inv ON inv.item_id = s2.ing_id
    -- Join with the ingredient table to get the weight of each ingredient
    LEFT JOIN ingredient ing ON ing.ing_id = s2.ing_id
)
