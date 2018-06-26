
'use strict';

var svg = dimple.newSvg("#chart", 590, 400);


d3.text("data/cpgf2017_filtered.csv", function (data) {

  var dsv = d3.dsvFormat(';');
  var data = dsv.parse(data);

  data.forEach(d => {
    var dateString = d.Data;
    dateString = dateString.substr(6, 4) + '-' + dateString.substr(3, 2) + '-' + dateString.substr(0, 2);
    d.date = new Date(dateString);
    ++d.Valor;
  });

    // Filter for 1 year
    data = dimple.filterData(data, "Mes", [
        "Jan-12", "Feb-12", "Mar-12", "Apr-12", "May-12", "Jun-12",
        "Jul-12", "Aug-12", "Sep-12", "Oct-12", "Nov-12", "Dec-12"
    ]);

    // Create the indicator chart on the right of the main chart
    var indicator = new dimple.chart(svg, data);

    // Pick blue as the default and orange for the selected month
    var defaultColor = indicator.defaultColors[0];
    var indicatorColor = indicator.defaultColors[2];

    // The frame duration for the animation in milliseconds
    var frame = 2000;

    var firstTick = true;

    // Place the indicator bar chart to the right
    indicator.setBounds(434, 49, 153, 311);

    // Add dates along the y axis
    var y = indicator.addCategoryAxis("y", "Mes");
    y.addOrderRule("Mes", "Desc");

    // Use sales for bar size and hide the axis
    var x = indicator.addMeasureAxis("x", "Valor");
    // x.hidden = true;

    // Add the bars to the indicator and add event handlers
    var s = indicator.addSeries(null, dimple.plot.bar);
    s.addEventHandler("click", onClick);
    // Draw the side chart
    indicator.draw();

    // Remove the title from the y axis
    y.titleShape.remove();

    // Remove the lines from the y axis
    y.shapes.selectAll("line,path").remove();

    // Move the y axis text inside the plot area
    y.shapes.selectAll("text")
            .style("text-anchor", "start")
            .style("font-size", "11px")
            .attr("transform", "translate(18, 0.5)");

    // This block simply adds the legend title. I put it into a d3 data
    // object to split it onto 2 lines.  This technique works with any
    // number of lines, it isn't dimple specific.
    svg.selectAll("title_text")
            .data(["Click bar to select",
                "and pause. Click again",
                "to resume animation"])
            .enter()
            .append("text")
            .attr("x", 435)
            .attr("y", function (d, i) { return 15 + i * 12; })
            .style("font-family", "sans-serif")
            .style("font-size", "10px")
            .style("color", "Black")
            .text(function (d) { return d; });

    // Manually set the bar colors
    s.shapes
            .attr("rx", 10)
            .attr("ry", 10)
            .style("fill", function (d) { return (d.y === 'Jan-12' ? indicatorColor.fill : defaultColor.fill) })
            .style("stroke", function (d) { return (d.y === 'Jan-12' ? indicatorColor.stroke : defaultColor.stroke) })
            .style("opacity", 0.4);

    // Draw the main chart
    var bubbles = new dimple.chart(svg, data);
    bubbles.setBounds(60, 50, 355, 310)
    bubbles.addMeasureAxis("x", "Data");
    bubbles.addMeasureAxis("y", "Valor");
    bubbles.addSeries(["OrgSuperior", "UnidadeGestora", "Favorecido"], dimple.plot.bubble)
    bubbles.addLegend(60, 10, 410, 60);

    // Add a storyboard to the main chart and set the tick event
    var story = bubbles.setStoryboard("Mes", onTick);
    // Change the frame duration
    story.frameDuration = frame;
    // Order the storyboard by date
    story.addOrderRule("Data");

    // Draw the bubble chart
    bubbles.draw();

    // Orphan the legends as they are consistent but by default they
    // will refresh on tick
    bubbles.legends = [];
    // Remove the storyboard label because the chart will indicate the
    // current month instead of the label
    story.storyLabel.remove();

    // On click of the side chart
    function onClick(e) {
        // Pause the animation
        story.pauseAnimation();
        // If it is already selected resume the animation
        // otherwise pause and move to the selected month
        if (e.yValue === story.getFrameValue()) {
            story.startAnimation();
        } else {
            story.goToFrame(e.yValue);
            story.pauseAnimation();
        }
    }

    // On tick of the main charts storyboard
    function onTick(e) {
        if (!firstTick) {
            // Color all shapes the same
            s.shapes
                    .transition()
                    .duration(frame / 2)
                    .style("fill", function (d) { return (d.y === e ? indicatorColor.fill : defaultColor.fill) })
                    .style("stroke", function (d) { return (d.y === e ? indicatorColor.stroke : defaultColor.stroke) });
        }
        firstTick = false;
    }
});
