CREATE TABLE unlabeled_image_predictions (
    image_id INT PRIMARY KEY,
    score FLOAT CHECK (score >= 0.0 AND score <= 1.0)
);

WITH ordered_images AS (
    SELECT 
        image_id, 
        score,
        ROW_NUMBER() OVER (ORDER BY score ASC) AS asc_rank,
        ROW_NUMBER() OVER (ORDER BY score DESC) AS desc_rank
    FROM unlabeled_image_predictions
)
SELECT image_id, score
FROM ordered_images
WHERE asc_rank % 3 = 1 OR desc_rank % 3 = 1
ORDER BY image_id;
