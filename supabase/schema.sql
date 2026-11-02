-- ====================================================================
-- KITLUY POS - SUPABASE (POSTGRESQL) SCHEMA
-- ប្រព័ន្ធគ្រប់គ្រងការលក់សម្រាប់ហាងសំបកកង់ អាគុយ ប្រេងម៉ាស៊ីន និងគ្រឿងបន្លាស់
-- ====================================================================

-- 1. បង្កើត ENUM ប្រភេទមុខទំនិញ
DO $$ BEGIN
    CREATE TYPE product_category AS ENUM (
        'tires', 'batteries', 'engineOil', 'spareParts', 'services'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. តារាងយានយន្ត និងអតិថិជន (Vehicles & Customers)
CREATE TABLE IF NOT EXISTS vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plate_number TEXT UNIQUE NOT NULL, -- ភ្នំពេញ 2BC-8899
    model TEXT NOT NULL,              -- Toyota Prius 2010
    current_mileage INT DEFAULT 0,    -- 135,400 km
    customer_name TEXT DEFAULT 'អតិថិជនទូទៅ',
    customer_phone TEXT,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. តារាងមុខទំនិញ និងសេវាកម្ម (Products & Services)
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,        -- Barcode ឬ SKU ឧ. MIC-2155517
    name_kh TEXT NOT NULL,            -- ឈ្មោះជាភាសាខ្មែរ
    name_en TEXT,                     -- ឈ្មោះជាភាសាអង់គ្លេស
    category product_category NOT NULL,
    unit_price_usd NUMERIC(10, 2) NOT NULL,
    cost_price_usd NUMERIC(10, 2) DEFAULT 0.0,
    stock_quantity INT DEFAULT 0,
    min_stock_alert INT DEFAULT 5,
    unit TEXT DEFAULT 'សំបក',
    image_url TEXT,
    attributes JSONB DEFAULT '{}'::jsonb, -- Tire size, DOT, Battery Ah, Oil viscosity, OEM
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. តារាងវិក្កយបត្រ (Orders)
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_no TEXT UNIQUE NOT NULL,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL,
    mechanic_name TEXT,
    exchange_rate NUMERIC(10, 2) NOT NULL DEFAULT 4100.0,
    subtotal_usd NUMERIC(10, 2) NOT NULL,
    discount_usd NUMERIC(10, 2) DEFAULT 0.0,
    trade_in_usd NUMERIC(10, 2) DEFAULT 0.0, -- កាត់អាគុយចាស់
    total_usd NUMERIC(10, 2) NOT NULL,
    total_khr INT NOT NULL,
    status TEXT DEFAULT 'completed',
    next_service_mileage INT,
    next_service_date DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. តារាងទំនិញលម្អិតក្នុងវិក្កយបត្រ (Order Items)
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    quantity INT NOT NULL DEFAULT 1,
    unit_price_usd NUMERIC(10, 2) NOT NULL,
    discount_usd NUMERIC(10, 2) DEFAULT 0.0,
    trade_in_usd NUMERIC(10, 2) DEFAULT 0.0,
    line_total_usd NUMERIC(10, 2) NOT NULL,
    note TEXT
);

-- 6. តារាងការទូទាត់ប្រាក់ (Payments)
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    payment_method TEXT NOT NULL, -- bakongKHQR, cashUSD, cashKHR, splitCash
    paid_usd NUMERIC(10, 2) DEFAULT 0.0,
    paid_khr INT DEFAULT 0,
    change_usd NUMERIC(10, 2) DEFAULT 0.0,
    change_khr INT DEFAULT 0,
    khqr_reference TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. Function & Trigger កាត់ស្តុកដោយស្វ័យប្រវត្តិពេលលក់ចេញ
CREATE OR REPLACE FUNCTION deduct_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE id = NEW.product_id AND category != 'services';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_deduct_stock ON order_items;
CREATE TRIGGER trigger_deduct_stock
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION deduct_product_stock();

-- 8. បញ្ចូលទិន្នន័យគំរូចាប់ផ្តើម (Seed Data)
INSERT INTO products (code, name_kh, name_en, category, unit_price_usd, cost_price_usd, stock_quantity, min_stock_alert, unit, attributes)
VALUES 
('MIC-PRIM4-2155517', 'សំបកកង់ Michelin Primacy 4 215/55R17', 'Michelin Primacy 4 (215/55R17)', 'tires', 95.0, 78.0, 24, 8, 'សំបក', '{"size":"215/55R17","brand":"Michelin","dot":"2424","warranty":24}'::jsonb),
('BRD-DUEL-2656517', 'សំបកកង់ Bridgestone Dueler A/T 697 265/65R17', 'Bridgestone Dueler A/T 697 (265/65R17)', 'tires', 145.0, 122.0, 16, 4, 'សំបក', '{"size":"265/65R17","brand":"Bridgestone","dot":"1824","warranty":36}'::jsonb),
('GS-MF-80D26L', 'អាគុយ GS Maintenance Free 12V 70Ah (80D26L)', 'GS MF Battery 12V 70Ah (80D26L)', 'batteries', 78.0, 60.0, 18, 5, 'គ្រាប់', '{"capacityAh":70,"terminal":"JIS 80D26L","rebate":10.0}'::jsonb),
('VAR-SLV-DIN80', 'អាគុយ Varta Silver Dynamic 12V 80Ah DIN80', 'Varta Silver Dynamic 12V 80Ah DIN80', 'batteries', 128.0, 102.0, 7, 3, 'គ្រាប់', '{"capacityAh":80,"terminal":"DIN80","rebate":12.0}'::jsonb),
('MOT-HTECH-5W30', 'ប្រេងម៉ាស៊ីន Motul H-Tech 100 Plus 5W-30 (4L)', 'Motul H-Tech 100 Plus 5W-30 (4L)', 'engineOil', 38.0, 29.0, 25, 6, 'កំប៉ុង', '{"viscosity":"5W-30","volume":4.0,"type":"Fully Synthetic"}'::jsonb),
('MOB-AFE-0W20', 'ប្រេងម៉ាស៊ីន Mobil 1 Advanced Fuel 0W-20 (4L Hybrid)', 'Mobil 1 Adv Fuel Economy 0W-20 4L', 'engineOil', 45.0, 36.0, 15, 5, 'កំប៉ុង', '{"viscosity":"0W-20","volume":4.0,"type":"Advanced Synthetic"}'::jsonb),
('04152-YZZA1', 'តម្រងប្រេងម៉ាស៊ីន Toyota Genuine (04152-YZZA1)', 'Toyota Genuine Oil Filter (04152-YZZA1)', 'spareParts', 5.5, 3.2, 50, 15, 'គ្រាប់', '{"oem":"04152-YZZA1","compatibility":"Prius / Camry / RAV4"}'::jsonb),
('SRV-TIRE-MTB', 'សេវាដោះប្តូរសំបកកង់ និងថ្លឹងកង់ (៤ គ្រាប់)', 'Tire Mounting & Wheel Balancing (4 Wheels)', 'services', 10.0, 0.0, 999, 0, 'ដង', '{}'::jsonb),
('SRV-WHEEL-ALIGN', 'សេវាតម្រង់កង់ឡាស៊ែរ 3D (Wheel Alignment)', '3D Laser Wheel Alignment Service', 'services', 15.0, 0.0, 999, 0, 'ដង', '{}'::jsonb)
ON CONFLICT (code) DO NOTHING;

