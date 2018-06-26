function draw(raw) {
  'use strict';
  var dsv = d3.dsvFormat(';');
  var data = dsv.parse(raw);

  data.forEach(d => {
    var dateString = d.Data;
    dateString = dateString.substr(6, 4) + '-' + dateString.substr(3, 2) + '-' + dateString.substr(0, 2);
    d.date = new Date(dateString);
    ++d.Valor;
  });

  var margin = { top: 30, bottom: 30, left: 40, right: 30 };
  var width = 1100;
  var height = 600;
  var radius = 4;

  var svg = d3
    .select('#chart')
    .append('svg')
    .classed('alimentacao', true);

  var timeExtent = d3.extent(data, d => d.date);

  var maxHeight = d3.max(data, d => d.Valor);

  var timeScale = d3
    .scaleTime()
    .domain(timeExtent)
    .rangeRound([0 + margin.left, width - margin.right]);

  var heightScale = d3
    .scaleLinear()
    .domain([0, maxHeight])
    .range([height - margin.bottom, 0 + margin.top]);

  var xAxis = d3.axisBottom().scale(timeScale);

  var yAxis = d3.axisLeft().scale(heightScale);

  var brush = d3.brushX().extent(timeExtent);
  // .on('brush', brushed);

  svg
    .style('height', height)
    .style('width', width)
    .style('border', '2px solid black');

  svg
    .append('g')
    .selectAll('circle')
    .data(data)
    .enter()
    .append('circle')
    .attr('cx', d => timeScale(d.date))
    .attr('cy', d => heightScale(d.Valor))
    .attr('r', radius)
    .attr('fill', 'silver')
    .attr('stroke', 'blue')
    .attr('title', d => d.Data)
    .style('opacity', 0.7);

  svg
    .append('g')
    .style('transform', 'translateX(' + margin.left + 'px)')
    .call(yAxis);

  svg
    .append('g')
    .style('transform', 'translate(0,' + (height - margin.bottom) + 'px)')
    .call(xAxis);
}
